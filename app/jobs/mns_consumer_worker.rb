# 阿里云MNS消息消费者Worker
# 使用Sidekiq定时任务持续监听MNS队列
class MnsConsumerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :zheli_low, retry: false

  # 每次处理的最大消息数
  MAX_MESSAGES_PER_RUN = 10
  
  # 长轮询等待时间(秒)
  WAIT_SECONDS = 5

  def perform
    logger.info "开始接收MNS消息..."
    
    begin
      client = AliyunMnsConfig.client
      
      # 批量接收消息
      messages = receive_messages(client, MAX_MESSAGES_PER_RUN)
      
      if messages.empty?
        #logger.info "MNS队列为空,无消息需要处理"
        return
      end
      
      #logger.info "接收到 #{messages.size} 条MNS消息"
      
      # 处理每条消息
      messages.each do |message|
        process_message(message, client)
      end
      
      #logger.info "成功处理 #{messages.size} 条MNS消息"
      
    rescue => e
      logger.error "MNS消息处理失败: #{e.message}"
      logger.error e.backtrace.join("\n")
      raise e
    end
  end

  private

  # 接收消息
  def receive_messages(client, count)
    messages = []
    
    count.times do
      begin
        message = client.receive_message(wait_seconds: WAIT_SECONDS)
        messages << message if message
      rescue => e
        logger.error "接收MNS消息失败: #{e.message}"
        break
      end
    end
    
    messages
  end

  # 处理单条消息
  def process_message(message, client)
    logger.info "处理MNS消息 ID: #{message[:message_id]}"
    
    begin
      decoded_body = decode_message_body(message[:message_body])
      
      #logger.info "消息内容(原始): #{message[:message_body][0..200]}..." if message[:message_body].length > 200
      #logger.info "消息内容(解码后): #{decoded_body[0..200]}..." if decoded_body.length > 200
      
      # 尝试解析为JSON
      body = parse_json_content(decoded_body)
      
      # 根据消息类型进行不同处理
      handle_message(body, message)
      
      # 删除已处理的消息
      if Rails.env.production?
        client.delete_message(message[:receipt_handle])
        #logger.info "消息已处理并删除: #{message[:message_id]}"
      end
      
    rescue => e
      logger.error "消息处理异常: #{e.message}"
      logger.error e.backtrace.join("\n")
      # 不删除消息,让它可以重新被消费
      raise e
    end
  end

  # Base64解码消息体
  def decode_message_body(raw_body)
    return raw_body if raw_body.blank?
    
    begin
      # Base64解码并强制转换为UTF-8编码
      decoded = Base64.decode64(raw_body).force_encoding('UTF-8')
      logger.debug "消息Base64解码成功"
      decoded
    rescue => e
      logger.warn "Base64解码失败,使用原始内容: #{e.message}"
      raw_body
    end
  end
  
  # 解析JSON内容
  def parse_json_content(content)
    return content if content.blank?
    
    begin
      parsed = JSON.parse(content)
      logger.debug "消息JSON解析成功"
      parsed
    rescue JSON::ParserError => e
      logger.debug "消息不是JSON格式,返回原始内容: #{e.message}"
      content
    end
  end

  # 处理JSON格式消息
  def handle_message(data, message)
    logger.info "收到JSON消息: #{data.inspect}"

    if data["Name"] == "Act-Report" && data["State"].downcase == "success"
      if "completed" == data["MediaWorkflowExecution"]["State"].downcase
        oss_object = data["MediaWorkflowExecution"]["Input"]["InputFile"]["Object"]
        run_id = data["RunId"]

        content_file_url = "http://#{ENV["ALIYUN_OSS_BUCKET"]}.oss-#{ENV["ALIYUN_OSS_ENDPOINT"]}.aliyuncs.com/#{oss_object}"
        mps_act = MpsAct.create(oss_object: oss_object, run_id: run_id, content_file_url: content_file_url)

        #10分钟后检查一次
        SupplementWorker.perform_in(600, mps_act.id)

        chapter = Chapter.find_by(content_file_url: content_file_url)
        return if chapter.nil?

        #filename = chapter.content_file_url[/[^\/]+(?=\.[^\.]+$)/]
        filename = File.basename(chapter.content_file_url)

        data["MediaWorkflowExecution"]["ActivityList"].each do |x|
          next if x["State"] != "Success"

          case x["Name"]
          when "Act-ss-mp4-ld"
            chapter.ld_file_path = gen_file_path(x["Name"], run_id, filename)
          when "Act-ss-mp4-hd"
            chapter.hd_file_path = gen_file_path(x["Name"], run_id, filename)
          when "Act-ss-mp4-sd"
            chapter.sd_file_path  = gen_file_path(x["Name"], run_id, filename)
          end
        end

        chapter.act_state = true
        chapter.save
      end
    end
  end

  def gen_file_path(act_path, run_id, filename)
    "https://#{ENV["ALIYUN_OSS_BUCKET"]}.oss-#{ENV["ALIYUN_OSS_ENDPOINT"]}.aliyuncs.com/#{act_path}/#{run_id}/#{filename}"
  end

end

