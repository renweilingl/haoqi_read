class ChangeHeadImgToAuthors < ActiveRecord::Migration[7.1]
  def change
    change_column :authors, :head_img, :string, null: true
  end
end
