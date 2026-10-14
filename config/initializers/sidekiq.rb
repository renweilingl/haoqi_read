# frozen_string_literal: true

require "fileutils"

# 确保在Sidekiq初始化前加载.env文件
#if defined?(Dotenv)
#  Dotenv.load(Rails.root.join('.env').to_s)
#end

def build_sidekiq_redis_url
  if Rails.env.development? || Rails.env.test?
    password = ENV.fetch("REDIS_PASSWORD", nil)
    return "redis://#{password}@localhost:6379/0"
    #return "redis://localhost:6379/0"
  end

  host = ENV.fetch("REDIS_URL", nil)
  password = ENV.fetch("REDIS_PASSWORD", nil)
  return "redis://localhost:6379/0" unless host

  return host if host.start_with?("redis://")

  host_without_scheme = host.sub(%r{^https?://}, "")
  port_match = host_without_scheme.match(/:(\d+)$/)
  port = port_match ? port_match[1] : "6379"
  host_part = port_match ? host_without_scheme.sub(/:\d+$/, "") : host_without_scheme
  host_part = host_part.sub(%r{/$}, "")

  "redis://#{password ? ":#{password}@" : ""}#{host_part}:#{port}/0"
end

sidekiq_url = build_sidekiq_redis_url

Sidekiq.configure_server do |config|
  config.redis = { url: sidekiq_url }

  log_path = Rails.root.join("log/sidekiq.log")
  FileUtils.mkdir_p(log_path.dirname)
  config.logger = Logger.new(log_path.to_s, "daily")
  config.logger.level = ::Logger::INFO
end

Sidekiq.configure_client do |config|
  config.redis = { url: sidekiq_url }
end
