class AddCategoryToRank < ActiveRecord::Migration[7.1]
  def change
    add_column :ranks, :category_id, :bigint
  end
end
