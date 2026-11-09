class Admin::BooksController < ApplicationController
  before_action :require_login

  def index
    authorize Book
    @per_page = params[:per_page] || 20

    category_ids = Category.where(name: ["绘本"]).pluck(:id)
    @q = Book.where(category_id: category_ids).ransack(params[:q])
    @books = @q.result.order("id asc").paginate(page: params[:page], per_page: @per_page)

    @suppliers = Supplier.all
  end

  def new
    @book = Book.new(is_published: true)
    cat = Category.find_by(name: "绘本")
    @book.category_id = cat.id
    authorize @book
    @suppliers = Supplier.all
  end

  def create
    @book = Book.new(book_params)
    authorize @book
    @suppliers = Supplier.all

    if @book.save
      redirect_to :admin_books, notice: '绘本创建成功'
    else
      render :new
    end
  end

  def destroy
    #redirect_to admin_compilation_books_path(@compilation)
  end

  private
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
      :time_line,
      :content_description,
      :grade_ids => [],
      :category_sub_ids => []
    )
  end
end
