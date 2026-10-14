# frozen_string_literal: true

class Admin::UserStatsController < ApplicationController
  before_action :require_login
  
  def index
    @period = params[:period] || 'daily'
    @range = params[:range]&.to_i || default_range(@period)
    
    @stats = UserRegistrationStatsService.comprehensive_stats(@period, @range)
    
    respond_to do |format|
      format.html
      format.json { render json: @stats }
    end
  end
  
  private
  
  def default_range(period)
    case period
    when 'daily' then 30
    when 'weekly' then 12
    when 'monthly' then 12
    else 30
    end
  end
end
