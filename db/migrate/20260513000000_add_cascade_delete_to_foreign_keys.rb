# frozen_string_literal: true

class AddCascadeDeleteToForeignKeys < ActiveRecord::Migration[7.1]
  FK_PAIRS = [
    [:book_grades, :book_id, :books],
    [:book_grades, :grade_id, :grades],
    [:compilation_books, :book_id, :books],
    [:compilation_books, :compilation_id, :compilations],
    [:compilation_grades, :compilation_id, :compilations],
    [:compilation_grades, :grade_id, :grades],
    [:category_sub_books, :book_id, :books],
    [:category_sub_books, :category_sub_id, :category_subs],
    [:chapters, :book_id, :books],
  ].freeze

  def up
    # 1. 清理孤儿数据
    FK_PAIRS.each do |table, column, ref_table|
      execute <<~SQL
        DELETE #{table} FROM #{table}
        LEFT JOIN #{ref_table} ON #{ref_table}.id = #{table}.#{column}
        WHERE #{ref_table}.id IS NULL
      SQL
    end

    # 2. 重建 FK 为 cascade
    FK_PAIRS.each do |table, column, ref_table|
      begin
        remove_foreign_key table, column: column
      rescue ArgumentError
        # FK doesn't exist, skip
      end
      add_foreign_key table, ref_table, column: column, on_delete: :cascade
    end
  end

  def down
    FK_PAIRS.each do |table, column, ref_table|
      begin
        remove_foreign_key table, column: column
      rescue ArgumentError
        # FK doesn't exist, skip
      end
      add_foreign_key table, ref_table, column: column
    end
  end
end
