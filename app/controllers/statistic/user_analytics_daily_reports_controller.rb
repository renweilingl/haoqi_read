class Statistic::UserAnalyticsDailyReportsController < ApplicationController
  before_action :require_login
  before_action :get_data

  def index
  end

  private
  def get_data
    cond = {}

    @start_date = Time.now.to_date - 7.days
    @end_date = Time.now.to_date
    if params[:start_date].present?
      @start_date = params[:start_date]
      cond[:stat_date_gteq] = Date.parse(params[:start_date]).strftime("%Y-%m-%d")
    end

    if params[:end_date].present?
      @end_date = params[:end_date]
      cond[:stat_date_lteq] = Date.parse(params[:end_date]).strftime("%Y-%m-%d")
    end

    @q = UserAnalyticsDaily.ransack(cond)
    @resource = @q.result
  end
end
