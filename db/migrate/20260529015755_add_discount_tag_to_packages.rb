class AddDiscountTagToPackages < ActiveRecord::Migration[7.1]
  def change
    add_column :packages, :discount_tag, :string, :limit => 32, :default => ""
  end
end
