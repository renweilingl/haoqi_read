class FileUploadJob < ApplicationJob
  queue_as :zheli_high
  sidekiq_options retry: false

  def perform(oss_key, file_path, mime)
    file = File.open(file_path)
    oss_path = AliyunOss.instance.put(oss_key, file, {'content_type': mime})
    logger.info "FileUploadJob oss_path: #{oss_path}"

    file.close
    cleanup_temp_file(file_path)

    book = Book.find_by(file_url: "http://#{ENV["ALIYUN_OSS_BUCKET"]}.oss-#{ENV["ALIYUN_OSS_ENDPOINT"]}.aliyuncs.com/#{oss_key}")
    return if book.nil?

    return unless ["epub", "pdf"].include? book.file_type

    if Rails.env.production?
      url = "https://api.zheliyuedu.cn/api/books/import"

      data = {uuid: AppUser.first.uuid, id: book.id}
      res = HTTParty.post(url, body: data.to_json, headers: {'Content-Type' => 'application/json'}).body
      logger.info "FileUploadJob import book res: #{res}"
    end
  end

  def cleanup_temp_file(file_path)
    return unless file_path.start_with?('/tmp/') || file_path.include?('tmp/uploads')

    if File.exist?(file_path)
      File.delete(file_path)
      Rails.logger.info "Cleaned up temp file: #{file_path}"
    end
  rescue => e
    Rails.logger.warn "Cleanup temp file failed: #{e.message}"
  end
end
