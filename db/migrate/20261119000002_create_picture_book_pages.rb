# frozen_string_literal: true

# 绘本页面数据表（与 haoqi_voicebook 共享）
# 生产环境可能已存在，使用 if_not_exists 避免重复创建
class CreatePictureBookPages < ActiveRecord::Migration[7.1]
  def up
    return if table_exists?(:picture_book_pages)

    create_table :picture_book_pages do |t|
      t.bigint :book_id, null: false, comment: '图书ID'
      t.integer :page_number, null: false, comment: '页码（跨页图按 01.jpg 顺序）'
      t.string :image_key, comment: '页面图片 OSS 路径'
      t.string :image_url, comment: '页面图片公网 URL'
      t.text :plain_text, comment: 'OCR 出的整页文字'
      t.json :ocr_raw, comment: 'OCR 原始返回（重试不再重复调用）'
      t.integer :start_ms, comment: '本页朗读起点（由 ASR 气口定出）'
      t.integer :end_ms, comment: '本页朗读终点'
      t.integer :timing_start_ms, comment: '资源包 时间.txt 给的起点（对照用）'
      t.integer :timing_end_ms, comment: '资源包 时间.txt 给的终点（对照用）'
      t.json :lines, comment: '行窗口与逐字 token（ch/py/kw/b）'
      t.integer :word_count, default: 0, null: false, comment: '本页汉字数'

      t.timestamps
    end

    add_index :picture_book_pages, %i[book_id page_number], unique: true
    add_index :picture_book_pages, :book_id
  end

  def down
    drop_table :picture_book_pages if table_exists?(:picture_book_pages)
  end
end
