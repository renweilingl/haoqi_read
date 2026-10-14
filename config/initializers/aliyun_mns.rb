# 阿里云MNS配置 - 使用REST API方式
require 'base64'
require 'openssl'
require 'time'
require 'cgi'
require 'nokogiri'

# 确保环境变量已加载(特别是Sidekiq环境)
if defined?(Dotenv) && ENV['ALIYUN_ACCESS_KEY_ID'].nil?
  Dotenv.load(Rails.root.join('.env').to_s)
end

class AliyunMnsClient
  attr_reader :endpoint, :access_key_id, :access_key_secret, :queue_name
  
  MNS_VERSION = '2015-06-06'
  
  def initialize(endpoint:, access_key_id:, access_key_secret:, queue_name:)
    # 清理Endpoint - 移除末尾的斜杠
    @endpoint = endpoint.to_s.strip.chomp('/')
    
    # 确保使用HTTP协议(MNS默认使用HTTP)
    # 如果用户配置了HTTPS,也保留,但MNS通常使用HTTP
    @endpoint = @endpoint.sub(%r{^https?://}, '')
    @endpoint = "http://#{@endpoint}" unless @endpoint.start_with?('http://') || @endpoint.start_with?('https://')
    
    @access_key_id = access_key_id.to_s.strip
    @access_key_secret = access_key_secret.to_s.strip
    @queue_name = queue_name.to_s.strip
    
    # 始终记录初始化信息(包括production环境)
    logger.info "[MNS] Initialized with endpoint: #{@endpoint}, queue: #{@queue_name}"
    logger.info "[MNS] AccessKey ID: #{@access_key_id[0..10]}..." if Rails.env.development?
  end
  
  # 接收消息
  def receive_message(wait_seconds: 5)
    url = "#{endpoint}/queues/#{queue_name}/messages"
    params = { waitseconds: wait_seconds }
    
    response = http_get(url, params)
    
    #logger.info "[MNS] Receive message response code: #{response.code}"
    
    if response.code == 200 && response.body.present?
      #logger.info "[MNS] Successfully received message"
      parse_message(response.body)
    elsif response.code == 204 || response.code == 404
      # 204 No Content 或 404 MessageNotExist 表示队列为空
      #logger.info "[MNS] Queue is empty (#{response.code})"
      nil
    else
      logger.error "[MNS] Failed to receive message. Code: #{response.code}, Body: #{response.body[0..200]}"
      # 如果是其他错误(如签名错误),抛出异常
      if response.code >= 400 && response.code != 404
        raise "MNS API Error: #{response.code} - #{response.body}"
      end
      nil
    end
  end
  
  # 删除消息
  def delete_message(receipt_handle)
    url = "#{endpoint}/queues/#{queue_name}/messages"
    params = { ReceiptHandle: receipt_handle }
    
    response = http_delete(url, params)
    response.code == 204
  end
  
  private
  
  def logger
    Rails.logger
  end
  
  # 发送GET请求
  def http_get(url, params = {})
    query_string = params.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
    full_url = query_string.present? ? "#{url}?#{query_string}" : url
    
    # GET请求的资源路径需要包含查询字符串用于签名
    resource = "/queues/#{queue_name}/messages"
    resource_with_query = query_string.present? ? "#{resource}?#{query_string}" : resource
    
    headers = build_headers('GET', resource_with_query, '')
    
    response = HTTParty.get(full_url, headers: headers)
    
    # 调试信息
    if Rails.env.development?
      logger.info "[MNS] GET #{full_url}"
      logger.info "[MNS] Response Code: #{response.code}"
      logger.info "[MNS] Response Body: #{response.body[0..500]}" if response.body.present?
    end
    
    response
  end
  
  # 发送DELETE请求
  def http_delete(url, params = {})
    query_string = params.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
    full_url = query_string.present? ? "#{url}?#{query_string}" : url
    
    # DELETE请求的资源路径需要包含查询字符串用于签名
    resource = "/queues/#{queue_name}/messages"
    resource_with_query = query_string.present? ? "#{resource}?#{query_string}" : resource
    
    headers = build_headers('DELETE', resource_with_query, '')
    
    response = HTTParty.delete(full_url, headers: headers)
    
    # 调试信息
    if Rails.env.development?
      logger.info "[MNS] DELETE #{full_url}"
      logger.info "[MNS] Response Code: #{response.code}"
    end
    
    response
  end
  
  # 构建签名和请求头
  def build_headers(method, resource, query_string = '')
    date = Time.now.httpdate
    
    # 对于GET/DELETE请求,Content-MD5和Content-Type为空字符串
    content_md5 = ''
    content_type = ''
    
    # 构建签名字符串 - 严格按照阿里云MNS规范
    # 格式: VERB + "\n" + Content-MD5 + "\n" + Content-Type + "\n" + Date + "\n" + CanonicalizedMNSHeaders + "\n" + CanonicalizedResource
    sign_string = "#{method}\n#{content_md5}\n#{content_type}\n#{date}\nx-mns-version:#{MNS_VERSION}\n#{resource}"
    
    logger.info "[MNS] Sign String: #{sign_string.inspect}" if Rails.env.development?
    
    # 生成签名 - 使用HMAC-SHA1
    signature = Base64.strict_encode64(
      OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), access_key_secret, sign_string)
    )
    
    authorization = "MNS #{access_key_id}:#{signature}"
    
    logger.info "[MNS] Authorization: #{authorization[0..80]}..." if Rails.env.development?
    
    {
      'Authorization' => authorization,
      'Date' => date,
      'x-mns-version' => MNS_VERSION
      # GET/DELETE请求不发送Content-Type header
    }
  end
  
  # 解析消息XML
  def parse_message(xml_body)
    doc = Nokogiri::XML(xml_body)
    
    {
      message_id: doc.at('MessageId')&.text,
      message_body: doc.at('MessageBody')&.text,
      receipt_handle: doc.at('ReceiptHandle')&.text,
      dequeue_count: doc.at('DequeueCount')&.text&.to_i || 0,
      enqueue_time: doc.at('EnqueueTime')&.text,
      next_visible_time: doc.at('NextVisibleTime')&.text
    }
  end
end

# 全局MNS客户端实例
class AliyunMnsConfig
  def self.client
    # 检查环境变量是否已正确设置
    unless ENV['ALIYUN_ACCESS_KEY_ID'] && ENV['ALIYUN_ACCESS_KEY_SECRET']
      logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
      logger.warn "[MNS] Warning: Environment variables not loaded, attempting to reload .env"
      if defined?(Dotenv)
        Dotenv.load(Rails.root.join('.env').to_s)
      end
    end
    
    @client ||= AliyunMnsClient.new(
      endpoint: ENV.fetch("ALIYUN_MNS_ENDPOINT"),
      access_key_id: ENV.fetch("ALIYUN_ACCESS_KEY_ID"),
      access_key_secret: ENV.fetch("ALIYUN_ACCESS_KEY_SECRET"),
      queue_name: ENV.fetch("ALIYUN_MNS_QUEUE_NAME", "zheli_read_queue")
    )
  end
end
