class AddIsFreeToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :is_free, :boolean, :default => false
  end
end
