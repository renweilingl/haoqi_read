class AddSubCatToContents < ActiveRecord::Migration[7.1]
  def change
    add_column :contents, :category_sub_id, :bigint
  end
end
