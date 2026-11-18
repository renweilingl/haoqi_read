class MediaVideoUploadJob < ApplicationJob
  queue_as :zheli_high
  sidekiq_options retry: false

  def perform(oss_path, file_path, mime)
    duration = MediaDurationService.extract_duration(file_path)

    file = File.open(file_path)
    AliyunOss.instance.put(oss_path, file, {'content_type': mime})
    file.close

    Rails.logger.info "MediaVideoUploadJob completed: #{oss_path}, duration: #{duration}"

    cleanup_temp_file(file_path)
  rescue => e
    Rails.logger.error "MediaVideoUploadJob failed: #{e.message}"
    raise
  end

  private

  def cleanup_temp_file(file_path)
    return unless file_path.include?('tmp/uploads')
    File.delete(file_path) if File.exist?(file_path)
  rescue => e
    Rails.logger.warn "Cleanup temp file failed: #{e.message}"
  end
end
