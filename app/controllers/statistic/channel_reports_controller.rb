class Statistic::ChannelReportsController < ApplicationController
  before_action :require_login
  before_action :get_data

  def index
    if request.xhr?
      items = @resource.order("stat_date desc").paginate(page: params[:page], per_page: params[:limit]).collect {|r|
        {record_date: r.stat_date,
         channel: r.channel,
         registrations: r.registrations,
         active_users: r.active_users,
         paid_users: r.paid_users,
         conversion_rate: r.conversion_rate,
         cac: r.cac
        }
      }
      render json: {data: items, code: 0, count: @resource.size}
    end
  end

  def export
    respond_to do |format|
      format.xls do
        send_data(xls_content_for(@resource.order("stat_date desc")),
                    type: "text/excel;charset=utf-8; header=present",
                    filename: "渠道分析数据.xls")
      end
      format.html
    end
  end

  private
  def xls_content_for(items)
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet name: "全局数据"

    blue = Spreadsheet::Format.new color: :black, weight: :normal, size: 12
    sheet1.row(0).default_format = blue
    head_array = %w[日期 渠道 新注册人数 活跃用户数 付费用户数 付费转化率 获客成本]
    sheet1.row(0).concat head_array

    idx = 1
    items.each do |r|
      data = [r.stat_date, r.channel, r.registrations, r.active_users, r.paid_users, r.conversion_rate, r.cac]
      sheet1.row(idx).concat data
      idx += 1
    end

    book.write xls_report
    xls_report.string
  end

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

    @q = DailyChannelStat.ransack(cond)
    @resource = @q.result
  end
end
