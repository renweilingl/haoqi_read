class AddContentDecsToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :content_description, :text
  end
end
