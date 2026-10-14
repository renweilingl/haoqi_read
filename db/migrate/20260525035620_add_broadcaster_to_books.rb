class AddBroadcasterToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :broadcaster, :string, :default => ""
  end
end
