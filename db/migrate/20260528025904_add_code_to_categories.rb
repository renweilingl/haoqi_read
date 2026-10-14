class AddCodeToCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :categories, :cat_code, :string, :limit => 16
  end
end
