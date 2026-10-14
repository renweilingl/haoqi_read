# frozen_string_literal: true

# 创建推荐内容小组表
class CreateContentGroups < ActiveRecord::Migration[7.1]
  def change
    create_table :content_groups, if_not_exists: true do |t|
      t.references :recommend, null: false, foreign_key: true, comment: '关联年级'
      t.string :name, null: false, comment: '小组名称'
      t.string :group_type, null: false, comment: '小组类型'
      t.integer :sn, default: 0, comment: '排序'

      t.timestamps
    end
  end
end
