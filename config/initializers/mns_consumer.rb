# 在Sidekiq服务器启动时自动启动MNS消费者
if defined?(Sidekiq)
  Sidekiq.configure_server do |config|
    config.on(:startup) do
      # 延迟2秒启动,确保Sidekiq完全初始化
      Thread.new do
        sleep 2
        MnsConsumerLauncher.start!
      end
    end
    
    config.on(:shutdown) do
      MnsConsumerLauncher.stop!
    end
  end
end
