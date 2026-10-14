class CreateCategorySubBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :category_sub_books, if_not_exists: true do |t|
      t.references :category_sub, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end

    add_index :category_sub_books, [:book_id, :category_sub_id], unique: true, if_not_exists: true
  end
end
