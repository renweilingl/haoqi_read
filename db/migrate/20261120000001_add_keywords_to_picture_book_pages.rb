# frozen_string_literal: true

class AddKeywordsToPictureBookPages < ActiveRecord::Migration[7.1]
  def change
    add_column :picture_book_pages, :keywords, :json
  end
end
