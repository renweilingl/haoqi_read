class Admin::MediaBooksController < ApplicationController
  before_action :require_login
  before_action :set_book, only: [:show, :edit, :update, :destroy, :auto_sort]

  def index
    authorize Book
    @per_page = params[:per_page] || 20

    category_ids = Category.where(name: ["有声", "视频"]).pluck(:id)
    @q = Book.where(category_id: category_ids).ransack(params[:q])
    @books = @q.result.order("id asc").paginate(page: params[:page], per_page: @per_page)

    @suppliers = Supplier.all 
  end

  def new
    @book = Book.new(is_published: true)
    cat = Category.find_by(name: "有声")
    @book.category_id = cat.id
    authorize @book
    @suppliers = Supplier.all
  end

  def create
    @book = Book.new(book_params)
    authorize @book
    @suppliers = Supplier.all

    if @book.save
      redirect_to :admin_media_books, notice: '图书创建成功'
    else
      render :new
    end
  end

  def show
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
      redirect_to admin_media_books_path, notice: '图书更新成功'
    else
      render :edit
    end
  end

  def auto_sort
    authorize @book

    seqs = []
    Chapter.where(book_id: @book.id).each do |chapter|
      sn = chapter.name.scan(/\d/).join
      if sn.blank?
        sn = 0
      else
        sn = sn.to_i
      end

      seqs << {id: chapter.id, sn: sn}
    end
    seqs = seqs.sort{|x,y| x[:sn] <=> y[:sn]}
    seqs.each_with_index do |x, idx|
      chapter = Chapter.find_by_id x[:id]
      chapter.update(sn: idx + 1)
    end

    render json: {code: 0}
  end

  def destroy
    authorize @book

    @book.destroy
    redirect_to :admin_media_books, notice: '图书删除成功'
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
      :broadcaster,
      :is_published,
      :content_description,
      :grade_ids => [],
      :category_sub_ids => []
    )
  end
end
