class AddPadImgUrlToSplashAds < ActiveRecord::Migration[7.1]
  def change
    add_column :splash_ads, :pad_image_url, :string
  end
end
