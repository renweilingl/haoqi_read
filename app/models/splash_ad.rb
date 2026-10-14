class SplashAd < ApplicationRecord
  audited
  
  belongs_to :book, optional: true
  belongs_to :compilation, optional: true
  has_and_belongs_to_many :grades, join_table: :splash_ad_grades
  
  # 链接类型
  LINK_TYPES = {
    single_book: '单本图书',
    compilation: '合辑'
  }.freeze

  PUSH_SCOPES = {
    all_users: '所有用户',
    age_range: '按年龄段',
    specific_users: '指定用户'
  }.freeze
  
  PUSH_MODES = {
    immediate: '定时推送',
    first_open_daily: '首次打开APP推送'
  }.freeze
  
  STATUSES = {
    draft: '草稿',
    active: '投放中',
    expired: '已过期',
    disabled: '已停用',
    deleted: '已删除'
  }.freeze
  
  enum :link_type, {
    single_book: 'single_book',
    compilation: 'compilation',
  }, prefix: true

  enum :push_scope, {
    all_users: 'all_users',
    age_range: 'age_range',
    specific_users: 'specific_users'
  }, prefix: true

  enum :push_mode, {
    immediate: 'immediate',
    first_open_daily: 'first_open_daily'
  }, prefix: true

  enum :status, {
    draft: 'draft',
    active: 'active',
    expired: 'expired',
    disabled: 'disabled',
    deleted: 'deleted'
  }, prefix: true 
  
  # 验证
  validates :image_url, presence: true
  validates :link_type, presence: true
  validates :push_scope, presence: true
  validates :push_mode, presence: true
  
  validate :link_type_consistency
  
  # 作用域
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_link_type, ->(link_type) { where(link_type: link_type) if link_type.present? }
  scope :by_push_scope, ->(push_scope) { where(push_scope: push_scope) if push_scope.present? }
  scope :active_now, -> { 
    where(status: :active)
  }
  scope :ordered, -> { order(created_at: :desc) }

  before_save do
    if link_type == "single_book"
      self.compilation_id = nil
    else
      self.book_id = nil
    end
  end

  def link_type_name
    LINK_TYPES[link_type.to_sym] || link_type
  end

  def push_scope_name
    PUSH_SCOPES[push_scope.to_sym] || push_scope
  end

  def push_mode_name
    PUSH_MODES[push_mode.to_sym] || push_mode
  end

  def status_name
    STATUSES[status.to_sym] || status
  end
  
  
  def time_range_display
    "#{start_time&.strftime('%Y-%m-%d %H:%M')} ~ #{end_time&.strftime('%Y-%m-%d %H:%M')}"
  end
  
  def click_rate_display
    return '0%' if send_count.zero?
    "#{((click_count.to_f / send_count) * 100).round(2)}%"
  end
  
  def active?
    status == 'active' && start_time <= Time.current && end_time >= Time.current
  end
  
  def expired?
    end_time < Time.current
  end
  
  def can_publish?
    status == 'draft' && start_time && end_time
  end
  
  def publish!
    return false unless can_publish?
    
    if start_time > Time.current
      update!(status: :scheduled)
    else
      update!(status: :active)
    end
  end
  
  def disable!
    update!(status: :disabled)
  end
  
  def enable!
    update!(status: :active)
  end

  def deleted?
    status == 'deleted'
  end
  
  private
  
  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    
    if end_time <= start_time
      errors.add(:end_time, '必须晚于开始时间')
    end
  end
  
  def link_type_consistency
    case link_type
    when 'single_book'
      errors.add(:book_id, '不能为空') if book_id.blank?
    when 'compilation'
      errors.add(:compilation_id, '不能为空') if compilation_id.blank?
    end
  end
  
  def self.ransackable_attributes(auth_object = nil)
    ["book_id", "category_id", "click_count", "created_at", "deleted_at", "delivery_rate", "end_time", "id", "id_value", "image_url", "link_type", "max_age", "min_age", "push_mode", "push_scope", "scheduled_at", "send_count", "start_time", "status", "updated_at", "user_group"]
  end
end
