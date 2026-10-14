# frozen_string_literal: true

class AddChapterIdToEbookPages < ActiveRecord::Migration[7.1]
  def change
    add_reference :ebook_pages, :chapter, foreign_key: true, after: :book_id
  end
end
