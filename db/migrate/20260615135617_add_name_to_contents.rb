class AddNameToContents < ActiveRecord::Migration[7.1]
  def change
    add_column :contents, :name, :string, :default => "", :limit => 16
    add_column :contents, :color, :string, :default => "", :limit => 16
  end
end
