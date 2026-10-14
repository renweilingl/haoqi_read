class AddMediIdToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :media_id, :bigint
  end
end
