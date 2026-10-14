class AddIsPublishedToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :is_published, :boolean, :default => false
  end
end
