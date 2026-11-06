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
    authorize Compilation

    book_ids = @compilation.book_ids || []
    if params[:book_ids].present?
      params[:book_ids].each do |book_id|
        book_ids << book_id.to_i unless book_ids.include? book_id.to_i
      end
    end
    @compilation.book_ids = book_ids
    @compilation.save!

    render json: {code: 0} 
  end

  def destroy
    @compilation.book_ids = @compilation.book_ids - [params[:id].to_i]
    @compilation.save!

    redirect_to admin_compilation_books_path(@compilation)
  end

  private
  def set_compilation
    @compilation  = Compilation.find(params[:compilation_id])
  end
end
