class CreateCompilationCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :compilation_categories, id: false, if_not_exists: true do |t|
      t.references :compilation, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.timestamps
    end

    # 添加复合索引
    add_index :compilation_categories, [:compilation_id, :category_id], unique: true, if_not_exists: true
  end
end
