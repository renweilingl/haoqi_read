# frozen_string_literal: true

# 统计数据表（从 voicebook 同步）
# 包含：user_analytics_daily, daily_reading_stats, daily_content_stats, daily_channel_stats
class CreateDailyStatsTables < ActiveRecord::Migration[7.1]
  def change
    # 用户分析每日预聚合表 — DAU/WAU/MAU/留存率
    unless table_exists?(:user_analytics_daily)
      create_table :user_analytics_daily do |t|
        t.string :stat_date, null: false, comment: '日期 YYYY-MM-DD'
        t.string :channel, limit: 32, null: false, default: '', comment: '渠道（空字符串=全部）'
        t.integer :dau, default: 0, comment: '日活'
        t.integer :wau, default: 0, comment: '周活'
        t.integer :mau, default: 0, comment: '月活'
        t.integer :new_users, default: 0, comment: '新注册用户'
        t.integer :registered_users, default: 0, comment: '累计注册用户'
        t.float :retention_day_1, default: 0.0, comment: '次日留存率'
        t.float :retention_day_7, default: 0.0, comment: '7日留存率'
        t.float :retention_day_30, default: 0.0, comment: '30日留存率'
        t.integer :total_sessions, default: 0, comment: '总打开次数'

        t.index %i[stat_date channel], unique: true
      end
    end

    # 用户阅读日统计表
    unless table_exists?(:daily_reading_stats)
      create_table :daily_reading_stats do |t|
        t.bigint :app_user_id, null: false, comment: '用户ID'
        t.string :stat_date, null: false, comment: '统计日期 YYYY-MM-DD'
        t.integer :session_count, default: 0, comment: '当日阅读次数'
        t.integer :total_duration_seconds, default: 0, comment: '当日总阅读时长(秒)'
        t.integer :books_read_count, default: 0, comment: '当日阅读书籍数'
        t.integer :avg_duration_seconds, default: 0, comment: '平均每次阅读时长(秒)'
        t.integer :completed_books_count, default: 0, comment: '当日完读书籍数'
        t.float :completion_rate, default: 0.0, comment: '完读率'
        t.integer :consecutive_days, default: 0, comment: '截至当日连续阅读天数'
        t.timestamps
      end

      add_index :daily_reading_stats, %i[app_user_id stat_date], unique: true
      add_index :daily_reading_stats, :stat_date
    end

    # 内容日统计表
    unless table_exists?(:daily_content_stats)
      create_table :daily_content_stats do |t|
        t.string :stat_date, null: false, comment: '统计日期 YYYY-MM-DD'
        t.bigint :book_id, comment: '图书ID（NULL=全平台汇总）'
        t.string :content_type, comment: '内容类型（ebook/audio/video/picture_book）'
        t.integer :clicks_count, default: 0, comment: '点击量'
        t.integer :reads_count, default: 0, comment: '阅读量（停留≥30秒）'
        t.integer :valid_plays_count, default: 0, comment: '有效播放量（≥10秒）'
        t.integer :completed_plays_count, default: 0, comment: '完播次数'
        t.integer :read_users_count, default: 0, comment: '阅读人数（去重）'
        t.integer :play_users_count, default: 0, comment: '播放人数（去重）'
        t.integer :completed_users_count, default: 0, comment: '完读人数（去重）'
        t.float :completion_rate, default: 0.0, comment: '完读率'
        t.timestamps
      end

      add_index :daily_content_stats, %i[stat_date book_id]
      add_index :daily_content_stats, :stat_date
    end

    # 渠道日统计表
    unless table_exists?(:daily_channel_stats)
      create_table :daily_channel_stats do |t|
        t.string :stat_date, null: false, comment: '统计日期 YYYY-MM-DD'
        t.string :channel, limit: 32, null: false, default: '', comment: '渠道（空字符串=全部）'
        t.integer :registrations, default: 0, comment: '当日注册量'
        t.integer :active_users, default: 0, comment: '当日活跃用户数'
        t.integer :paid_users, default: 0, comment: '当日付费用户数'
        t.decimal :paid_amount, precision: 10, scale: 2, default: 0, comment: '当日付费金额'
        t.float :conversion_rate, default: 0.0, comment: '付费转化率'
        t.decimal :cac, precision: 10, scale: 2, default: 0, comment: '获客成本'
        t.timestamps
      end

      add_index :daily_channel_stats, %i[stat_date channel], unique: true
      add_index :daily_channel_stats, :stat_date
    end
  end
end
