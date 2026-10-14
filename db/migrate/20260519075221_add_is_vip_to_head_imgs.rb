class AddIsVipToHeadImgs < ActiveRecord::Migration[7.1]
  def change
    add_column :head_imgs, :is_vip, :boolean, :default => false
    remove_column :head_imgs, :vip_type
  end
end
