# frozen_string_literal: true
class Admin::PictureBooksController < ApplicationController
  before_action :require_login
  before_action :set_book, only: [:show, :edit, :update, :destroy, :media_link, :update_media_link]

  def index
    authorize Book
    @per_page = params[:per_page] || 20

    category_ids = Category.where(name: ["图书", "漫画"]).pluck(:id)
    @q = Book.where(category_id: category_ids).ransack(params[:q])
    @picture_books = @q.result.order("id asc").paginate(page: params[:page], per_page: @per_page)

    @suppliers = Supplier.all
  end

  def show
    authorize @book
  end

  def new
    @book = Book.new(is_published: true)
    cat = Category.find_by(name: "图书")
    @book.category_id = cat.id
    authorize @book
    @suppliers = Supplier.all
  end

  def create
    @book = Book.new(book_params)
    authorize @book
    @suppliers = Supplier.all

    if @book.save
      if ["epub", "pdf"].include? @book.file_type
        BookImportJob.perform_later(@book.id)
      end
      redirect_to :admin_picture_books, notice: '图书创建成功'
    else
      render :new
    end
  end

  def edit
    authorize @book
    @suppliers = Supplier.all
  end

  def update
    authorize @book
    @suppliers = Supplier.all

    old_file_url = @book.file_url

    if @book.update(book_params)
      # 文件重新上传时，清除旧章节/页面并重新导入
      if book_params[:file_url].present? && book_params[:file_url] != old_file_url
        @book.ebook_pages.delete_all
        @book.catalogues.delete_all
        @book.update_column(:import_status, 0)
        BookImportJob.perform_later(@book.id)
      end
      redirect_to admin_picture_books_path, notice: '图书更新成功'
    else
      render :edit
    end
  end

  def destroy
    authorize @book
    @book.destroy
    redirect_to admin_picture_books_path, notice: '图书删除成功'
  end

  def media_link
    #authorize @book
    audio_category = Category.find_by(name: "有声")
    @audio_books = Book.where(category_id: audio_category.id).order(:name) if audio_category
  end

  def update_media_link
    #authorize @book
    media_id = params[:media_id]
    
    if media_id.blank?
      @book.update(media_id: nil)
      redirect_to admin_picture_books_path, notice: '已取消有声关联'
    else
      audio_book = Book.find_by(id: media_id)
      if audio_book && audio_book.category.name == "有声"
        @book.update(media_id: media_id)
        redirect_to admin_picture_books_path, notice: '有声关联成功'
      else
        redirect_to admin_picture_books_path, alert: '关联失败:选择的不是有声图书'
      end
    end
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(
      :name,
      :cover_image_url,
      :supplier_id,
      :category_id,
      :book_level_id,
      :author_id,
      :file_url,
      :file_name,
      :file_type,
      :is_free,
      :is_published,
      :content_description,
      :grade_ids => [],
      :category_sub_ids => []
    )
  end
end
