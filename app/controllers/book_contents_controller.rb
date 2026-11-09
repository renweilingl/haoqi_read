class BookContentsController < ApplicationController
  before_action :require_login
  include PictureBooksHelper

  def destroy
    content = BookContent.find_by_id params[:id]
    book_id = content.book_id

    content.destroy
    auto_sort_contents(book_id)

    redirect_to contents_admin_book_path(book_id)
  end

  def update_timeline
    content = BookContent.find_by_id params[:id]
    content.update(start_at: params[:start_at], deal_at: params[:deal_at])
    render json: {code: 0}
  end
end
