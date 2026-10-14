# MNS消息消费调度器
# 通过Sidekiq的周期性任务持续监听MNS队列
class MnsConsumerScheduler
  include Sidekiq::Worker
  sidekiq_options queue: :zheli_low, retry: false

  # 检查间隔(秒) - 每次处理完后等待多久再次检查
  CHECK_INTERVAL = 120

  def perform
    # 执行MNS消息消费
    MnsConsumerWorker.new.perform
    
    # 延迟指定时间后再次执行,形成持续监听
    if Rails.env.production?
      self.class.perform_in(CHECK_INTERVAL.seconds)
    end
    
    #logger.info "MNS消费者调度完成,#{CHECK_INTERVAL}秒后再次检查"
  rescue => e
    logger.error "MNS消费者调度失败: #{e.message}"
    # 即使出错也继续调度,保证服务不中断
    self.class.perform_in(CHECK_INTERVAL.seconds)
  end
end
