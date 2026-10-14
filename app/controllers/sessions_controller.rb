class SessionsController < ApplicationController
  #skip_before_action :require_login, only: [:new, :create]
  before_action :require_login, only: [:destroy]
  layout 'login'

  def new
    redirect_to :admin_grades if logged_in?
  end

  def create
    user = login(params[:email], params[:password])
    
    if user
      #remember_me! if params[:remember_me] == '1'
      respond_to do |format|
        format.html do
          flash[:notice] = "登录成功！"
          redirect_to :admin_grades
        end
        format.json { render json: { success: true, message: "登录成功", user: user_json(user) } }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = "邮箱或密码错误"
          render :new, status: :unprocessable_entity
        end
        format.json { render json: { success: false, error: "邮箱或密码错误" }, status: :unauthorized }
      end
    end
  end

  def destroy
    logout
    respond_to do |format|
      format.html do
        flash[:notice] = "已退出登录"
        redirect_to login_path
      end
      format.json { render json: { success: true, message: "已退出登录" } }
    end
  end

  private

  def user_json(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      role_name: user.role_name
    }
  end
end
