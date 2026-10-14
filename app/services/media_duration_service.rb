# frozen_string_literal: true

class MediaDurationService
  # Extract duration in seconds from a local media file using ffprobe
  # Returns integer seconds, or nil if extraction fails
  def self.extract_duration(file_path)
    return nil unless File.exist?(file_path)

    output = `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "#{file_path}" 2>&1`
    return nil unless $?.success?

    duration_seconds = output.strip.to_f
    duration_seconds.round
  rescue => e
    Rails.logger.error "MediaDurationService error: #{e.message}"
    nil
  end
end