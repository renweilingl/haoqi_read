# frozen_string_literal: true

class DailyContentStat < ApplicationRecord
  self.table_name = 'daily_content_stats'
  belongs_to :book, optional: true

  scope :by_date, ->(date) { where(stat_date: date) }
  scope :by_book, ->(book_id) { where(book_id: book_id) }
  scope :platform_summary, -> { where(book_id: nil) }
end
