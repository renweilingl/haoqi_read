class Admin::BooksController < ApplicationController
  before_action :require_login
  before_action :set_compilation

  def index
    authorize Compilation

    @books = @compilation.books.includes(:category)
  end

  def new
    authorize Compilation

    book_ids = []
    @compilation.grades.each do |grade|
      book_ids  += grade.book_ids
    end
    book_ids.uniq!

    book_ids = book_ids - @compilation.book_ids

    @q = Book.where(id: book_ids).ransack(params[:q])
    @books = @q.result

    if request.xhr?
      items = @books.collect {|r|
        {id: r.id,
         category_name: r.category.name,
         name: r.name,
        }
      }
      render json: {data: items, code: 0}
    end
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
