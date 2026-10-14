# frozen_string_literal: true

# 创建推荐内容表
class CreateRecommends < ActiveRecord::Migration[7.1]
  def change
    create_table :recommends, if_not_exists: true do |t|
      t.references :grade, null: false, comment: '关联年级'
      t.string :name, null: false, comment: '推荐内容名称'
      t.integer :sn, default: 0, comment: '排序'
      t.boolean :status, default: true, comment: '状态: true发布/false草稿'

      t.timestamps
    end

    add_index :recommends, [:grade_id, :sn], if_not_exists: true
  end
end
