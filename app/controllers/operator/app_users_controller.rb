class Operator::AppUsersController < ApplicationController
  before_action :require_login
  before_action :get_data

  def index
    @per_page = params[:per_page] || 20

    @app_users = @app_users.paginate(page: params[:page], per_page: @per_page)
  end

  def new_gift_vip
    @app_user = AppUser.find_by_id params[:id]
  end

  def add_gift_vip
    @app_user = AppUser.find_by_id params[:id]

    ds = params[:effective_days].to_i.days

    if @app_user.vip_expires_at.blank? || @app_user.vip_expires_at < Time.now
      @app_user.update(vip_expires_at: Time.now + ds, is_vip: true)
    else
      @app_user.update(vip_expires_at: @app_user.vip_expires_at + ds, is_vip: true)
    end

    flash[:success] = "会员赠送成功"
    redirect_to action: :index
  end

  def export
    respond_to do |format|
      format.xls do
        send_data(xls_content_for(@app_users.order("id asc")),
                    type: "text/excel;charset=utf-8; header=present",
                    filename: "用户数据.xls")
      end
      format.html
    end
  end

  private
  def xls_content_for(items)
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet name: "用户数据"

    blue = Spreadsheet::Format.new color: :black, weight: :normal, size: 14
    sheet1.row(0).default_format = blue
    head_array = %w[用户ID 渠道 注册时间 手机号 是否付费 累计付费金额]
    sheet1.row(0).concat head_array

    idx = 1
    items.each do |r|
      data = [r.id, r.channel, r.created_at.strftime('%Y-%m-%d %H:%M:%S'), r.phone, r.is_vip? ? "是" : "否", r.orders.paid.sum(:amount).round(2)]
      sheet1.row(idx).concat data
      idx += 1
    end

    book.write xls_report
    xls_report.string
  end

  def get_data
    cond = params[:q] || {}

    @start_date = Time.now.to_date - 1.year
    @end_date = Time.now.to_date
    if params[:start_date].present?
      @start_date = params[:start_date]
    end

    if params[:end_date].present?
      @end_date = params[:end_date]
    end
    cond[:created_at_gteq] = @start_date
    cond[:created_at_lteq] = @end_date

    @q = AppUser.includes(:orders).ransack(cond)
    @app_users = @q.result
  end
end
