class AddIsFreeToEbookPages < ActiveRecord::Migration[7.1]
  def change
    add_column :ebook_pages, :is_free, :boolean, :default => false
  end
end
