class Operator::PackagesController < ApplicationController
  before_action :require_login
  before_action :set_package, only: [:edit, :update, :destroy]

  def index
    authorize Package

    @packages = Package.where(is_delete: false).order("id asc")
  end

  def new
    authorize Package
    @package = Package.new
  end

  def create
    authorize Package

    @package = Package.new(package_params)

    if @package.save
      flash[:notice] = "套餐创建成功！"
      redirect_to :operator_packages
    else
      flash.now[:alert] = "套餐创建失败：#{@package.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize Package
  end

  def update
    authorize Package

    if @package.update(package_params)
      flash[:success] = '套餐更新成功'
      redirect_to :operator_packages
    else
      flash[:error] = @package.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    authorize Package

    @package.update(is_delete: true)

    flash[:notice] = "套餐删除成功！"
    redirect_to :operator_packages
  end

  private

  def set_package
    @package = Package.find(params[:id])
  end

  def package_params
    params.require(:package).permit(:name, :origin_price, :price, :sn, :effective_days, :is_discount, :discount_tag)
  end

end
