class Admin::AccountsController < ApplicationController
  before_action :require_login
  before_action :set_user, only: [:show, :edit, :update, :destroy, :reset_password]
  
  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  def index
    authorize User
    @per_page = params[:per_page] || 20
    @users = policy_scope(User).order(created_at: :desc).paginate(page: params[:page], per_page: @per_page)
  end

  def new
    authorize User
    @user = User.new
  end

  def create
    authorize User
    @user = User.new(user_params)
    
    if @user.save
      respond_to do |format|
        format.html do
          flash[:notice] = "账号创建成功！"
          redirect_to admin_accounts_path
        end
        format.json { render json: { success: true, message: "账号创建成功", user: account_json(@user) } }
      end
    else
      respond_to do |format|
        format.html do
          render :new, status: :unprocessable_entity
        end
        format.json { render json: { success: false, errors: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    
    if @user.update(user_params)
      respond_to do |format|
        format.html do
          flash[:notice] = "账号更新成功！"
          redirect_to admin_accounts_path
        end
        format.json { render json: { success: true, message: "账号更新成功", user: account_json(@user) } }
      end
    else
      respond_to do |format|
        format.html do
          render :edit, status: :unprocessable_entity
        end
        format.json { render json: { success: false, errors: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @user
    @user.destroy
    
    respond_to do |format|
      format.html do
        flash[:notice] = "账号删除成功！"
        redirect_to admin_accounts_path
      end
      format.json { render json: { success: true, message: "账号删除成功" } }
    end
  end

  def show
    authorize @user
  end

  def reset_password
    authorize @user, :reset_password?
    new_password = params[:password] || '123456'
    
    if @user.update(password: new_password, password_confirmation: new_password)
      respond_to do |format|
        format.html do
          flash[:notice] = "密码重置成功！新密码：#{new_password}"
          redirect_to admin_account_path(@user)
        end
        format.json { render json: { success: true, message: "密码重置成功", password: new_password } }
      end
    else
      respond_to do |format|
        format.html do
          flash[:alert] = "密码重置失败！"
          redirect_to admin_account_path(@user)
        end
        format.json { render json: { success: false, errors: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def account_json(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      role_name: user.role_name,
      created_at: user.created_at,
      updated_at: user.updated_at
    }
  end
end
