# frozen_string_literal: true

# 创建分类子类表
class CreateCategorySubs < ActiveRecord::Migration[7.1]
  def change
    create_table :category_subs, if_not_exists: true do |t|
      t.references :category, null: false, foreign_key: true, comment: '关联分类'
      t.string :name, null: false, comment: '子类名称'
      t.string :icon, comment: '图标URL'
      t.integer :sn, default: 0, comment: '排序'

      t.timestamps
    end
  end
end
