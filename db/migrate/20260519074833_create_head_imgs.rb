class CreateHeadImgs < ActiveRecord::Migration[7.1]
  def change
    create_table :head_imgs do |t|
      t.string :vip_type
      t.string :img_url

      t.timestamps
    end
  end
end
