class Admin::CataloguesController < ApplicationController
  before_action :require_login
  before_action :set_book

  def index
    authorize Book

    if request.xhr?
      items = @book.catalogues.order("chapter_number asc").paginate(page: params[:page], per_page: params[:limit]).collect {|r|
        {id: r.id,
         book_id: r.book_id,
         chapter_name: r.chapter_name,
         start_page_number: r.start_page_number,
         chapter_number: r.chapter_number,
         is_free: r.is_free,
         created_at: r.created_at.strftime('%Y-%m-%d'),
        }
      }
      render json: {data: items, code: 0, count: @book.catalogues.size}
    end
  end

  def edit
    @chapter = @book.catalogues.find(params[:id])

    authorize @book
  end

  def update
    authorize @book

    @chapter = @book.catalogues.find(params[:id])

    if @chapter.update(chapter_params)
      redirect_to admin_picture_book_catalogues_path(@book), notice: '图书更新成功'
    else
      render :edit
    end
  end

  def update_sn
    @book.catalogues.find(params[:id]).update(chapter_number: params[:sn])

    render json: {code: 0}
  end

  def batch_free
    @book.catalogues.where(id: params[:ids]).update_all(is_free: true)
    render json: {code: 0}
  end

  def batch_unfree
    @book.catalogues.where(id: params[:ids]).update_all(is_free: false)
    render json: {code: 0}
  end

  private

  def set_book
    @book = Book.find(params[:picture_book_id])
  end

  def chapter_params
    params.require(:catalogue).permit(
      :chapter_name,
      :chapter_number,
      :start_page_number,
      :is_free
    )
  end

end
