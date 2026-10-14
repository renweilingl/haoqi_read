class Admin::ChannelsController < ApplicationController
  before_action :require_login
  before_action :set_channel, only: [:edit, :update, :destroy]

  def index
    authorize Channel

    @per_page = params[:per_page] || 20

    @q = Channel.ransack(params[:q])
    @channels = @q.result.paginate(page: params[:page], per_page: @per_page)

    respond_to do |format|
      format.html
      format.json { render json: {
        success: true,
        categories: @channels.map(&:as_json),
        pagination: {
          current_page: @channels.current_page,
          total_pages: @channels.total_pages,
          total_count: @channels.total_entries,
          per_page: @channels.per_page
        }
      }}
    end
  end

  def new
    @channel = Channel.new
  end

  def create
    @channel = Channel.new(channel_params)

    if @channel.save
      redirect_to admin_channels_path, notice: '渠道创建成功'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @channel.update(channel_params)
      redirect_to admin_channels_path, notice: '渠道更新成功'
    else
      render :edit
    end
  end

  def destroy
    if @channel.destroy
      redirect_to admin_channels_path, notice: '渠道删除成功'
    else
      redirect_to admin_channels_path, alert: '删除失败'
    end
  end


  private
  def set_channel
    @channel = Channel.find(params[:id])
  end

  def channel_params
    params.require(:channel).permit(
      :name, :version
    )
  end
end
