# MNS消费者启动器
# 用于在应用启动时自动开始监听MNS队列
class MnsConsumerLauncher
  def self.start!
    return unless enabled?
    
    logger.info "启动MNS消息消费者..."
    
    # 检查是否已经有调度任务在运行
    if scheduler_running?
      logger.info "MNS消费者已经在运行中"
      return
    end
    
    # 启动调度器
    MnsConsumerScheduler.perform_async
    
    logger.info "MNS消息消费者已启动"
  end
  
  def self.stop!
    logger.info "停止MNS消息消费者..."
    # Sidekiq的定时任务会自动结束,不需要手动停止
    logger.info "MNS消息消费者已停止"
  end
  
  def self.enabled?
    ENV.fetch("MNS_CONSUMER_ENABLED", "false") == "true"
  end
  
  private
  
  def self.logger
    Rails.logger
  end
  
  def self.scheduler_running?
    # 检查是否有正在运行的调度任务
    # 这里可以根据实际情况实现更精确的检查逻辑
    false
  end
end
