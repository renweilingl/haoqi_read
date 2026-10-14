class AddBookLevelToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :book_level_id, :bigint unless column_exists?(:books, :book_level_id)
  end
end
