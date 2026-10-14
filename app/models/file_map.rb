# encoding: UTF-8
#require 'logger' 
class FileMap 
  def initialize(src, file_type)
    @verb, @headers  = "GET", {}
    @src = src

    ts = 3600
    @date = Time.now.to_i + ts

    p_bkt = src=~/.oss-cn-/
    s_bkt = src[0..p_bkt-1].gsub("http://", '').gsub("https://", '')

    s_sub = src[p_bkt..-1]
    p_obj = s_sub=~/.com/
    s_obj = s_sub[p_obj+5..-1]

    @res = "/" + s_bkt + "/" + s_obj

    @resources = { :path => @res}
  end

  def secrity_src
    @src + "?" + "OSSAccessKeyId=#{ENV["ALIYUN_ACCESS_KEY_ID"]}" + "&Expires=#{@date}" + "&Signature=#{get_signature}" 
  end

  def get_signature
    prefix = "x-oss-"

    content_md5 = @headers['content-md5'] || ""
    content_type = @headers['content-type'] || ""

    cano_headers = @headers.select { |k, v| k.start_with?(prefix) }
                 .map { |k, v| [k.downcase.strip, v.strip] }
                 .sort.map { |k, v| [k, v].join(":") + "\n" }.join

    cano_res = @resources[:path] || "/"
    sub_res = (@resources[:sub_res] || {})
             .sort.map { |k, v| v ? [k, v].join("=") : k }.join("&")
    cano_res += "?#{sub_res}" unless sub_res.empty?

    string_to_sign =
      "#{@verb}\n#{content_md5}\n#{content_type}\n#{@date}\n" +
      "#{cano_headers}#{cano_res}"

    CGI.escape(sign(string_to_sign))
  end

  def sign(string_to_sign)
    key = ENV["ALIYUN_ACCESS_KEY_SECRET"]
    Base64.strict_encode64(
    OpenSSL::HMAC.digest('sha1', key, string_to_sign))
  end
end
