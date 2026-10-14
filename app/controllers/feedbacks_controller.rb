class FeedbacksController < ApplicationController
  before_action :require_login

  def index
    authorize Feedback

    @per_page = params[:per_page] || 20

    @feedbacks = Feedback.all.order("id desc").paginate(page: params[:page], per_page: @per_page)
  end
end
