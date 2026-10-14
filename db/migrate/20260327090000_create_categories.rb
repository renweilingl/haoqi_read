class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories, if_not_exists: true do |t|
      t.string :name, null: false              # 分类名称
      t.integer :level, null: false, default: 1            # 分类级别（1:一级/年级, 2:二级, 3:三级）
      t.integer :sn, default: 0        # 排序
      t.boolean :active, default: true         # 是否启用

      t.timestamps
    end

    add_index :categories, :level, if_not_exists: true
  end
end
