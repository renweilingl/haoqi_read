# frozen_string_literal: true

class DailyReadingStat < ApplicationRecord
  self.table_name = 'daily_reading_stats'
  belongs_to :app_user, class_name: 'AppUser'

  scope :by_date, ->(date) { where(stat_date: date) }
  scope :by_user, ->(user_id) { where(app_user_id: user_id) }
  scope :recent, ->(days = 30) { where("stat_date >= ?", days.days.ago.to_date.to_s) }
end
