# frozen_string_literal: true

class PushNotificationsController < ApplicationController
  before_action :require_login
  before_action :set_push_notification, only: [:show, :edit, :update, :destroy, :send_push]

  def index
    authorize PushNotification
    @per_page = params[:per_page] || 20

    @q = PushNotification.ransack(params[:q])
    @push_notifications = @q.result.sorted.paginate(page: params[:page], per_page: @per_page)
  end

  def show
    authorize @push_notification
  end

  def new
    @push_notification = PushNotification.new
    authorize @push_notification
  end

  def create
    @push_notification = PushNotification.new(push_params)
    authorize @push_notification

    if @push_notification.save
      PushJob.perform_later(@push_notification.id)
      redirect_to push_notifications_path, notice: '推送创建成功'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @push_notification
  end

  # 更新推送
  def update
    authorize @push_notification

    if @push_notification.update(push_params)
      PushJob.perform_later(@push_notification.id)
      redirect_to push_notifications_path, notice: '推送更新成功'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # 删除推送
  def destroy
    authorize @push_notification
    @push_notification.destroy
    redirect_to push_notifications_path, notice: '推送已删除'
  end

  # 发送推送（立即或定时）
  def send_push
    authorize @push_notification

    if @push_notification.scheduled? && @push_notification.scheduled_at > Time.current
      @push_notification.update(status: :scheduled)
      redirect_to push_notifications_path, notice: '推送已设为定时发送'
    else
      # 立即发送：模拟推送发送
      @push_notification.update(status: :sent, sent_at: Time.current, send_count: 1000, click_count: rand(200..800))
      redirect_to push_notifications_path, notice: '推送已发送'
    end
  end

  private

  def set_push_notification
    @push_notification = PushNotification.find(params[:id])
  end

  def push_params
    params.require(:push_notification).permit(
      :push_type,
      :title,
      :body,
      :link_url,
      :push_scope,
      :user_group,
      :status,
      :scheduled_at,
      :grade_ids => []
    )
  end
end
