namespace :reports do
  desc "任务测试"
  task :job_test => :environment do
    MpsAct.all.each do |mps|
      chapter = Chapter.find_by(content_file_url: mps.content_file_url)
      run_id = mps.run_id
      next if chapter.nil?

      name = File.basename(chapter.content_file_url)

      hd_file_path = "https://#{ENV["ALIYUN_OSS_BUCKET"]}.oss-#{ENV["ALIYUN_OSS_ENDPOINT"]}.aliyuncs.com/Act-ss-mp4-hd/#{run_id}/#{name}"
      ld_file_path = "https://#{ENV["ALIYUN_OSS_BUCKET"]}.oss-#{ENV["ALIYUN_OSS_ENDPOINT"]}.aliyuncs.com/Act-ss-mp4-ld/#{run_id}/#{name}"
      sd_file_path = "https://#{ENV["ALIYUN_OSS_BUCKET"]}.oss-#{ENV["ALIYUN_OSS_ENDPOINT"]}.aliyuncs.com/Act-ss-mp4-sd/#{run_id}/#{name}"

      chapter.update(hd_file_path: hd_file_path,
                     ld_file_path: ld_file_path,
                     sd_file_path: sd_file_path)

    end
    Chapter.where(content_file_type: "mp4").each do |x|
      next if x.ld_file_path.blank?

      x.update(ld_file_path: x.ld_file_path.gsub("mp4.mp4", "mp4"), hd_file_path: x.hd_file_path.gsub("mp4.mp4", "mp4"),  sd_file_path: x.sd_file_path.gsub("mp4.mp4", "mp4"))
    end
  end
end
