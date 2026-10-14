class AddRankToContents < ActiveRecord::Migration[7.1]
  def change
    add_column :contents, :rank_id, :bigint
  end
end
