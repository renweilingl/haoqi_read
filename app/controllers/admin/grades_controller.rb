class Admin::GradesController < ApplicationController
  before_action :require_login
  before_action :set_grade, only: [:show, :edit, :update, :destroy]

  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  def index
    authorize Grade
    @per_page = params[:per_page] || 20

    @grades = Grade.all.paginate(page: params[:page], per_page: @per_page)
  end

  def show
    authorize @grade

    respond_to do |format|
      format.html
      format.json { render json: { success: true, category: @grade.as_json } }
    end
  end

  def new
    authorize Grade
    @grade = Grade.new
  end

  def create
    authorize Grade

    @grade = Grade.new(grade_params)

    if @grade.save
      respond_to do |format|
        format.html do
          flash[:notice] = "年级创建成功！"
          redirect_to :admin_grades
        end
        format.json { render json: { success: true, message: "年级创建成功", category: @grade.as_json }, status: :created }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = "年级创建失败：#{@grade.errors.full_messages.join(', ')}"
          render :new, status: :unprocessable_entity
        end
        format.json { render json: { success: false, errors: @grade.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize @grade
  end

  def update
    authorize @grade

    if @grade.update(grade_params)
      respond_to do |format|
        format.html do
          flash[:notice] = "年级更新成功！"
          redirect_to :admin_grades
        end
        format.json { render json: { success: true, message: "年级更新成功", category: @grade.as_json } }
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:alert] = "年级更新失败：#{@grade.errors.full_messages.join(', ')}"
          render :edit, status: :unprocessable_entity
        end
        format.json { render json: { success: false, errors: @grade.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @grade

    if @grade.destroy
      respond_to do |format|
        format.html do
          flash[:notice] = "年级删除成功！"
          redirect_to :admin_grades
        end
        format.json { render json: { success: true, message: "年级删除成功" } }
      end
    else
      respond_to do |format|
        format.html do
          flash[:alert] = "年级删除失败"
          redirect_to admin_grades_path
        end
        format.json { render json: { success: false, error: "年级删除失败" }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_grade
    @grade = Grade.find(params[:id])
  end

  def grade_params
    params.require(:grade).permit(:name, :group_name, :description)
  end
end
