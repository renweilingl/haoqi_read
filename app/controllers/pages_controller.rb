class PagesController < ApplicationController

  def home
    redirect_to dashboard_path if logged_in?
  end

  def dashboard
    require_login
  end

end
