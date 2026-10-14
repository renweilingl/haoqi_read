class AddFileInfoToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :file_url, :string
    add_column :books, :file_name, :string
    add_column :books, :file_type, :string
  end
end
