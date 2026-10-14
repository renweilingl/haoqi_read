class Operator::OrdersController < ApplicationController
  before_action :require_login
  before_action :get_data

  def index
    authorize Order

    @per_page = params[:per_page] || 20

    @orders = @orders.paginate(page: params[:page], per_page: @per_page)
  end

  def export
    respond_to do |format|
      format.xls do
        send_data(xls_content_for(@orders.order("id asc")),
                    type: "text/excel;charset=utf-8; header=present",
                    filename: "订单数据.xls")
      end
      format.html
    end
  end

  private
  def xls_content_for(items)
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet name: "订单数据"

    blue = Spreadsheet::Format.new color: :black, weight: :normal, size: 12
    sheet1.row(0).default_format = blue
    head_array = %w[订单号 用户ID 渠道 金额 支付方式 支付时间 订单状态]
    sheet1.row(0).concat head_array

    idx = 1
    items.each do |r|
      data = [r.order_no, r.app_user_id, r.channel, r.amount.round(2), r.payment_method, r.created_at.strftime('%Y-%m-%d %H:%M:%S'), r.hum_status]
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

    @q = Order.includes(:app_user, :package).ransack(cond)
    @orders = @q.result
  end
end
