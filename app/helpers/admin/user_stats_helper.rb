# frozen_string_literal: true

module Admin::UserStatsHelper
  # 根据统计维度返回中文标签
  def period_label_text(period)
    case period
    when 'daily' then '天'
    when 'weekly' then '周'
    when 'monthly' then '月'
    else '天'
    end
  end
  
  # 获取最高/最低值的显示标签
  def stat_extremum_label(stat, period)
    case period
    when 'daily'
      stat[:date]
    when 'weekly'
      stat[:week]
    when 'monthly'
      stat[:month]
    else
      stat[:date]
    end
  end
end
