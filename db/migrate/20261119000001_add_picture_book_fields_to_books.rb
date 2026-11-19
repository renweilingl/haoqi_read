# frozen_string_literal: true

# 绘本相关字段（与 haoqi_voicebook 共享）
# 生产环境 books 表已存在，仅添加新列
class AddPictureBookFieldsToBooks < ActiveRecord::Migration[7.1]
  def up
    # 检查列是否已存在（幂等）
    return if column_exists?(:books, :source_book_no)

    add_column :books, :source_book_no, :string, comment: "外部资源编号（供应资源包名，如 61355）"
    add_column :books, :narration_oss_key, :string, comment: "旁白音频 OSS 路径"
    add_column :books, :narration_oss_url, :string, comment: "旁白音频公网 URL"
    add_column :books, :total_duration_ms, :integer, comment: "旁白总时长（毫秒）"
    add_column :books, :asr_raw, :json, comment: "ASR 原始句子与词时间（重试不再重复调用）"
    add_column :books, :book_json_oss_key, :string, comment: "book.json OSS 路径"
    add_column :books, :book_json_oss_url, :string, comment: "book.json 公网 URL"
    add_column :books, :dict_json_oss_key, :string, comment: "dict.json OSS 路径"
    add_column :books, :dict_json_oss_url, :string, comment: "dict.json 公网 URL"

    add_index :books, :source_book_no unless index_exists?(:books, :source_book_no)
  end

  def down
    remove_index :books, :source_book_no if index_exists?(:books, :source_book_no)
    remove_column :books, :dict_json_oss_url if column_exists?(:books, :dict_json_oss_url)
    remove_column :books, :dict_json_oss_key if column_exists?(:books, :dict_json_oss_key)
    remove_column :books, :book_json_oss_url if column_exists?(:books, :book_json_oss_url)
    remove_column :books, :book_json_oss_key if column_exists?(:books, :book_json_oss_key)
    remove_column :books, :asr_raw if column_exists?(:books, :asr_raw)
    remove_column :books, :total_duration_ms if column_exists?(:books, :total_duration_ms)
    remove_column :books, :narration_oss_url if column_exists?(:books, :narration_oss_url)
    remove_column :books, :narration_oss_key if column_exists?(:books, :narration_oss_key)
    remove_column :books, :source_book_no if column_exists?(:books, :source_book_no)
  end
end
