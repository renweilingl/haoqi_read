class AddSerializeStateCompilations < ActiveRecord::Migration[7.1]
  def change
    add_column :compilations, :serialize_state, :string, :limit => 16
  end
end
