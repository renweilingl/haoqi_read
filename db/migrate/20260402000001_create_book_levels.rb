class CreateBookLevels < ActiveRecord::Migration[7.1]
  def change
    create_table :book_levels, if_not_exists: true do |t|
      t.string :name, limit: 50, null: false, comment: '等级名称'
      t.integer :sn, null: false, default: 0, comment: '序号'
      t.timestamps
    end
  end
end
