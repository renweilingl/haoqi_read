class Admin::CategoriesController < ApplicationController
  before_action :require_login
  before_action :set_category, only: [:show, :edit, :update, :destroy, :toggle_active, :subs]

  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  def index
    authorize Category
    @per_page = params[:per_page] || 20

    @q = Category.ransack(params[:q])
    @categories = @q.result.paginate(page: params[:page], per_page: @per_page)
  end

  def show
    authorize @category

    respond_to do |format|
      format.html
      format.json { render json: { success: true, category: @category.as_json } }
    end
  end

  def new
    authorize Category
    @category = Category.new
  end

  def create
    authorize Category

    @category = Category.new(category_params)


    if @category.save
      respond_to do |format|
        format.html do
          flash[:notice] = "分类创建成功！"
          redirect_to :admin_categories
        end
        format.json { render json: { success: true, message: "分类创建成功", category: @category.as_json }, status: :created }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = "分类创建失败：#{@category.errors.full_messages.join(', ')}"
          render :new, status: :unprocessable_entity
        end
        format.json { render json: { success: false, errors: @category.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize @category
  end

  def update
    authorize @category

    if @category.update(category_params)
      respond_to do |format|
        format.html do
          flash[:notice] = "分类更新成功！"
          redirect_to :admin_categories
        end
        format.json { render json: { success: true, message: "分类更新成功", category: @category.as_json } }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = "分类更新失败：#{@category.errors.full_messages.join(', ')}"
          render :edit, status: :unprocessable_entity
        end
        format.json { render json: { success: false, errors: @category.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @category

    if @category.destroy
      respond_to do |format|
        format.html do
          flash[:notice] = "分类删除成功！"
          redirect_to :admin_categories
        end
        format.json { render json: { success: true, message: "分类删除成功" } }
      end
    else
      respond_to do |format|
        format.html do
          flash[:alert] = "分类删除失败"
          redirect_to admin_category_path(@category)
        end
        format.json { render json: { success: false, error: "分类删除失败" }, status: :unprocessable_entity }
      end
    end
  end

  def subs
    render json: { sub_opts: render_to_string(partial: 'sub_opts', layout: false) }
  end

  # 切换启用状态
  def toggle_active
    authorize @category
    @category.update!(active: !@category.active)

    respond_to do |format|
      format.html { redirect_to request.referer || admin_categories_path }
      format.json { render json: { success: true, active: @category.active, message: @category.active ? "分类已启用" : "分类已禁用" } }
    end
  end

  # 批量操作
  def batch_action
    authorize Category

    action = params[:batch_action]
    category_ids = params[:category_ids] || []

    if category_ids.empty?
      respond_to do |format|
        format.html do
          flash[:alert] = "请选择要操作的分类"
          redirect_to admin_categories_path
        end
        format.json { render json: { success: false, error: "请选择要操作的分类" }, status: :bad_request }
      end
      return
    end

    @categories = Category.where(id: category_ids)

    case action
    when 'activate'
      @categories.update_all(active: true)
      message = "成功启用 #{@categories.count} 个分类"
    when 'deactivate'
      @categories.update_all(active: false)
      message = "成功禁用 #{@categories.count} 个分类"
    when 'delete'
      @categories.destroy_all
      message = "成功删除 #{@categories.count} 个分类"
    else
      message = "未知的操作"
    end

    respond_to do |format|
      format.html do
        flash[:notice] = message
        redirect_to admin_categories_path
      end
      format.json { render json: { success: true, message: message } }
    end
  end

  # 分类统计
  def statistics
    authorize Category
    @statistics = Category.statistics

    respond_to do |format|
      format.html
      format.json { render json: { success: true, statistics: @statistics } }
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
