class AddColorTorecommends < ActiveRecord::Migration[7.1]
  def change
    add_column :recommends, :color, :string, :default => "", :limit => 16
  end
end
