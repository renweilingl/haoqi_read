# frozen_string_literal: true

# 创建推送通知记录表
class CreatePushNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :push_notifications do |t|
      # 推送类型：系统通知 / 活动通知
      t.integer :push_type, null: false, default: 0

      # 内容
      t.string :title, null: false, limit: 20
      t.string :body, null: false, limit: 50
      t.string :link_url, limit: 500

      # 推送范围
      t.integer :push_scope, null: false, default: 0
      t.integer :min_age        # 年龄段-最小年龄
      t.integer :max_age        # 年龄段-最大年龄
      t.text :user_group        # 指定用户群体（JSON格式）

      # 推送时间
      t.integer :status, null: false, default: 0
      t.datetime :scheduled_at  # 定时推送时间
      t.datetime :sent_at       # 实际发送时间

      # 推送统计
      t.integer :send_count, default: 0
      t.integer :click_count, default: 0
      t.decimal :delivery_rate, precision: 5, scale: 2, default: 0.0

      t.boolean :is_delete, default: false

      t.timestamps
    end

    add_index :push_notifications, :status
    add_index :push_notifications, :push_type
  end
end
