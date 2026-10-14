class CreateRankContents < ActiveRecord::Migration[7.1]
  def change
    create_table :rank_contents do |t|
      t.belongs_to :rank
      t.bigint :compilation_id, comment: '合辑信息'
      t.bigint :book_id, comment: '单本信息'
      t.integer :sn, comment: '排序'

      t.timestamps
    end
  end
end
