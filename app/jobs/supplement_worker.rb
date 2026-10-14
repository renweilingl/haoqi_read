class SupplementWorker
  include Sidekiq::Worker
  sidekiq_options queue: :zheli_low, retry: false

  def perform(mps_act_id)
    logger.info "SupplementWorker start mps_act_id: #{mps_act_id}"
    mps = MpsAct.find_by_id mps_act_id
    return if mps.nil?

    chapter = Chapter.find_by(content_file_url: mps.content_file_url)
    return if chapter.nil?

    return unless chapter.ld_file_path.blank?

    run_id = mps.run_id
    #name = chapter.content_file_url[/[^\/]+(?=\.[^\.]+$)/]
    name = File.basename(chapter.content_file_url)
    
    hd_file_path = "https://#{ENV["ALIYUN_OSS_BUCKET"]}.oss-#{ENV["ALIYUN_OSS_ENDPOINT"]}.aliyuncs.com/Act-ss-mp4-hd/#{run_id}/#{name}"
    ld_file_path = "https://#{ENV["ALIYUN_OSS_BUCKET"]}.oss-#{ENV["ALIYUN_OSS_ENDPOINT"]}.aliyuncs.com/Act-ss-mp4-ld/#{run_id}/#{name}"
    sd_file_path = "https://#{ENV["ALIYUN_OSS_BUCKET"]}.oss-#{ENV["ALIYUN_OSS_ENDPOINT"]}.aliyuncs.com/Act-ss-mp4-sd/#{run_id}/#{name}"

    chapter.update(hd_file_path: hd_file_path,
                   ld_file_path: ld_file_path,
                   sd_file_path: sd_file_path)
  end

end
