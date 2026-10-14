class CreatePackages < ActiveRecord::Migration[7.1]
  def change
    create_table :packages do |t|
      t.string :name,  comment: '套餐名字', limit: 16
      t.float :origin_price, comment: '原价'
      t.float :price, comment: '实际原价'
      t.integer :sn, comment: '排序', :default => 0
      t.integer :effective_days, comment: '有效天数'
      t.boolean :is_delete, :default =>  false

      t.timestamps
    end
  end
end
