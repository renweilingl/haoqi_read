class AddCompilationToSplashAds < ActiveRecord::Migration[7.1]
  def change
    add_column :splash_ads, :compilation_id, :bigint
    remove_column :splash_ads, :category_id
  end
end
