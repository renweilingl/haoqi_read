class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers, if_not_exists: true do |t|
      t.string :name, null: false, comment: '供应商名称'
      t.timestamps
    end

    add_index :suppliers, :name, if_not_exists: true
  end
end
