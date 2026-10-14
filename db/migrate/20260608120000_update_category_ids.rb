# frozen_string_literal: true

class UpdateCategoryIds < ActiveRecord::Migration[7.1]
  def up
    # 临时禁用外键检查
    execute 'SET FOREIGN_KEY_CHECKS = 0'

    # 15->1 图书, 16->2 漫画, 17->3 音频(改名), 18->4 视频
    id_map = { 15 => 1, 16 => 2, 17 => 3, 18 => 4 }
    name_map = { 15 => '图书', 16 => '漫画', 17 => '音频', 18 => '视频' }

    # 先更新 category_subs 中的 category_id
    id_map.each do |old_id, new_id|
      execute "UPDATE category_subs SET category_id = #{new_id} WHERE category_id = #{old_id}"

      # 再更新 categories 表的 id 和 name
      execute "UPDATE categories SET id = #{new_id}, name = '#{name_map[old_id]}' WHERE id = #{old_id}"
    end

    execute 'SET FOREIGN_KEY_CHECKS = 1'
  end

  def down
    execute 'SET FOREIGN_KEY_CHECKS = 0'

    id_map = { 1 => 15, 2 => 16, 3 => 17, 4 => 18 }
    name_map = { 15 => '图书', 16 => '漫画', 17 => '有声', 18 => '视频' }

    id_map.each do |new_id, old_id|
      execute "UPDATE category_subs SET category_id = #{old_id} WHERE category_id = #{new_id}"

      execute "UPDATE categories SET id = #{old_id}, name = '#{name_map[old_id]}' WHERE id = #{new_id}"
    end

    execute 'SET FOREIGN_KEY_CHECKS = 1'
  end
end
