class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  #allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  #stale_when_importmap_changes

  # Sorcery 和 Pundit
  include Sorcery::Controller
  include Pundit::Authorization

  #rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :current_user, :logged_in?

  def logged_in?
    !!current_user
  end

  protected

  def not_authenticated
    respond_to do |format|
      format.html do
        flash[:alert] = "请先登录"
        redirect_to login_path
      end
      format.json { render json: { success: false, error: "请先登录" }, status: :unauthorized }
    end
  end

  def require_login
    redirect_to login_path, alert: "请先登录" unless logged_in?
  end

  private

  def user_not_authorized(exception)
    respond_to do |format|
      format.html do
        flash[:alert] = exception.message
        redirect_to(request.referer || root_path)
      end
      format.json { render json: { success: false, error: exception.message }, status: :forbidden }
    end
  end
end
