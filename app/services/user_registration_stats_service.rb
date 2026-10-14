# frozen_string_literal: true

# 用户注册统计服务
class UserRegistrationStatsService
  # 按天统计注册量(最近N天)
  def self.daily_registrations(days = 30)
    start_date = days.days.ago.to_date
    end_date = Date.today
    
    # 使用SQL分组统计,性能更好
    results = AppUser.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
                     .group("DATE(created_at)")
                     .count
    
    # 填充缺失的日期(没有注册的日期显示为0)
    (start_date..end_date).map do |date|
      {
        date: date.strftime('%Y-%m-%d'),
        count: results[date] || 0,
        weekday: date.strftime('%A')
      }
    end
  end
  
  # 按周统计注册量(最近N周)
  def self.weekly_registrations(weeks = 12)
    results = []
    
    weeks.times do |i|
      week_start = i.weeks.ago.to_date.beginning_of_week(:monday)
      week_end = week_start.end_of_week(:monday)
      
      count = AppUser.where(created_at: week_start.beginning_of_day..week_end.end_of_day).count
      
      results << {
        week: "#{week_start.strftime('%m-%d')} ~ #{week_end.strftime('%m-%d')}",
        week_start: week_start.strftime('%Y-%m-%d'),
        week_end: week_end.strftime('%Y-%m-%d'),
        count: count
      }
    end
    
    results.reverse # 从早到晚排序
  end
  
  # 按月统计注册量(最近N月)
  def self.monthly_registrations(months = 12)
    results = []
    
    months.times do |i|
      month = i.months.ago.to_date
      month_start = month.beginning_of_month
      month_end = month.end_of_month
      
      count = AppUser.where(created_at: month_start.beginning_of_day..month_end.end_of_day).count
      
      results << {
        month: month.strftime('%Y年%m月'),
        year_month: month.strftime('%Y-%m'),
        count: count
      }
    end
    
    results.reverse # 从早到晚排序
  end
  
  # 获取综合统计数据(用于ECharts)
  def self.comprehensive_stats(period = 'daily', range = 30)
    case period
    when 'daily'
      data = daily_registrations(range)
      {
        type: 'daily',
        labels: data.map { |d| d[:date] },
        values: data.map { |d| d[:count] },
        weekdays: data.map { |d| d[:weekday] },
        total: data.sum { |d| d[:count] },
        average: (data.sum { |d| d[:count] }.to_f / data.size).round(1),
        max: data.max_by { |d| d[:count] },
        min: data.min_by { |d| d[:count] }
      }
    when 'weekly'
      data = weekly_registrations(range)
      {
        type: 'weekly',
        labels: data.map { |d| d[:week] },
        values: data.map { |d| d[:count] },
        week_ranges: data.map { |d| "#{d[:week_start]} ~ #{d[:week_end]}" },
        total: data.sum { |d| d[:count] },
        average: (data.sum { |d| d[:count] }.to_f / data.size).round(1),
        max: data.max_by { |d| d[:count] },
        min: data.min_by { |d| d[:count] }
      }
    when 'monthly'
      data = monthly_registrations(range)
      {
        type: 'monthly',
        labels: data.map { |d| d[:month] },
        values: data.map { |d| d[:count] },
        year_months: data.map { |d| d[:year_month] },
        total: data.sum { |d| d[:count] },
        average: (data.sum { |d| d[:count] }.to_f / data.size).round(1),
        max: data.max_by { |d| d[:count] },
        min: data.min_by { |d| d[:count] }
      }
    end
  end
end
