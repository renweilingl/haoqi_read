class Admin::EbookPagesController < ApplicationController
  before_action :require_login                                                   
  before_action :set_book                                                        
                                                                                 
  def index                                                                      
    authorize Book

    if request.xhr?
      items = @book.ebook_pages.order("page_number asc").paginate(page: params[:page], per_page: params[:limit]).collect {|r|
        {id: r.id,
         book_id: r.book_id,
         is_free: r.is_free,
         page_number: r.page_number,
    #     image_url: r.image_url
        }
      }
      render json: {data: items, code: 0, count: @book.ebook_pages.size}
    end
  end

  def batch_free                                                                 
    @book.ebook_pages.where(id: params[:ids]).update_all(is_free: true)
    render json: {code: 0}
  end
                                                                                 
  def batch_unfree
    @book.ebook_pages.where(id: params[:ids]).update_all(is_free: false)
    render json: {code: 0}
  end

  private                                                                        
  def set_book
    @book = Book.find(params[:picture_book_id])
  end
end
