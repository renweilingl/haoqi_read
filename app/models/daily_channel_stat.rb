# frozen_string_literal: true

class DailyChannelStat < ApplicationRecord
  self.table_name = 'daily_channel_stats'

  scope :by_date, ->(date) { where(stat_date: date) }
  scope :by_channel, ->(channel) { where(channel: channel) }
  scope :platform_summary, -> { where(channel: '') }

  def self.ransackable_attributes(auth_object = nil)
    ["active_users", "cac", "channel", "conversion_rate", "created_at", "id", "id_value", "paid_amount", "paid_users", "registrations", "stat_date", "updated_at"]
  end
end
