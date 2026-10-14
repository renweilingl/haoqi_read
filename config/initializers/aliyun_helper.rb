class AliyunOss
  CarrierWave.configure do |config|
    config.storage           = :aliyun
    config.aliyun_access_id  = ENV["ALIYUN_ACCESS_KEY_ID"]
    config.aliyun_access_key = ENV["ALIYUN_ACCESS_KEY_SECRET"]
    config.aliyun_bucket     = ENV["ALIYUN_OSS_BUCKET"]
    config.aliyun_internal   = ENV["ALIYUN_OSS_INTERNAL"] == "true"
    config.aliyun_area       = ENV["ALIYUN_OSS_ENDPOINT"]
  end

  @uploader = CarrierWave::Uploader::Base.new
  @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)

  def self.instance
    @bucket
  end
end

class AliyunOssOpen
  CarrierWave.configure do |config|
    config.storage           = :aliyun
    config.aliyun_access_id  = ENV["ALIYUN_ACCESS_KEY_ID"]
    config.aliyun_access_key = ENV["ALIYUN_ACCESS_KEY_SECRET"]
    config.aliyun_bucket     = ENV["ALIYUN_OSS_BUCKET_OPEN"]
    config.aliyun_internal   = ENV["ALIYUN_OSS_INTERNAL"] == "true"
    config.aliyun_area       = ENV["ALIYUN_OSS_ENDPOINT"]
  end

  @uploader = CarrierWave::Uploader::Base.new
  @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)

  def self.instance
    @bucket
  end
end
