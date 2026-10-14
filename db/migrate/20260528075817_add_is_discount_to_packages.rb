class AddIsDiscountToPackages < ActiveRecord::Migration[7.1]
  def change
    add_column :packages, :is_discount, :boolean, :default => false
  end
end
