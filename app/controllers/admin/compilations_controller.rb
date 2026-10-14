# frozen_string_literal: true

class Admin::CompilationsController < ApplicationController
  before_action :require_login
  before_action :set_compilation, only: [:show, :edit, :update, :destroy, :books, :update_books]

  def index
    authorize Compilation

    @q = Compilation.ransack(params[:q])
    @compilations = @q.result.paginate(page: params[:page], per_page: @per_page)
  end

  def show
    authorize @compilation
  end

  def new
    @compilation = Compilation.new
    authorize @compilation
  end

  def create
    @compilation = Compilation.new(compilation_params)
    authorize @compilation

    if @compilation.save
      redirect_to admin_compilation_path(@compilation), notice: '合辑创建成功'
    else
      flash[:alert] = "合辑创建失败：#{@compilation.errors.full_messages.join(', ')}"
      logger.info @compilation.errors.full_messages.join(',')
      render :new
    end
  end

  def edit
    authorize Compilation
  end

  def update
    authorize Compilation

    if @compilation.update(compilation_params)
      redirect_to :admin_compilations, notice: '合辑更新成功'
    else
      render :edit
    end
  end

  def destroy
    authorize Compilation
    @compilation.destroy
    redirect_to admin_collections_path, notice: '合辑删除成功'
  end

  def books
    authorize Compilation

    @books = @compilation.books.includes(:category)

    #book_ids = []
    #@compilation.grades.each do |grade|
    #  book_ids  += grade.book_ids
    #end
    #book_ids.uniq!
    #@books = Book.where(id: book_ids)
  end

  def update_books
    book_ids = []
    if params[:bood_ids].present?
      params[:bood_ids].each do |x|
        book_ids << x[1]['value']
      end
    end
    @compilation.book_ids = book_ids
    @compilation.save!
    render json: {code: 0}
  end

  private

  def set_compilation
    @compilation = Compilation.find(params[:id])
  end

  def compilation_params
    params.require(:compilation).permit(
      :name,
      :banner_image_url,
      :banner_image_name,
      :landscape_cover_url,
      :landscape_cover_name,

      :editor_recommendation,
      :publisher,
      :total_count,
      :author,
      :tags,
      :serialize_state,

      :intro_image_url,
      :intro_image_name,
      :content_description,
      :grade_ids => [],
      :category_ids => []
    )
  end
end
