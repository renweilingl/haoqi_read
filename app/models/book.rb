# frozen_string_literal: true

class Book < ApplicationRecord
  audited
  belongs_to :supplier, optional: true
  belongs_to :category
  belongs_to :author, optional: true
  has_and_belongs_to_many :grades, join_table: :book_grades
  has_and_belongs_to_many :compilations, join_table: :compilation_books
  has_and_belongs_to_many :category_subs, join_table: :category_sub_books

  has_many :chapters, dependent: :destroy 
  has_many :catalogues, dependent: :destroy 
  has_many :contents, dependent: :destroy 
  has_many :splash_ads, dependent: :destroy 
  has_many :rank_contents, dependent: :destroy 
  has_many :ebook_pages, dependent: :destroy 

  # 验证
  validates :name, presence: true, length: { maximum: 100 }

  # 内容文件类型
  FILE_TYPES = {
    epub: 'epub',
    pdf: 'pdf',
    mp3: 'mp3',
    mp4: 'mp4'
  }.freeze

  FILE_TYPE_NAMES = {
    epub: 'EPUB电子书',
    pdf: 'PDF文档',
    mp3: '有声',
    mp4: '视频'
  }.freeze

  FILE_TYPE_ICONS = {
    epub: 'layui-icon-read',
    pdf: 'layui-icon-file-b',
    mp3: 'layui-icon-headset',
    mp4: 'layui-icon-video'
  }.freeze

  FILE_TYPE_COLORS = {
    epub: '#10b981',
    pdf: '#ef4444',
    mp3: '#8b5cf6',
    mp4: '#3b82f6'
  }.freeze

  def file_type_name
    FILE_TYPE_NAMES[file_type.to_sym] || file_type
  end

  def file_type_icon
    FILE_TYPE_ICONS[file_type.to_sym] || 'layui-icon-file'
  end

  def file_type_color
    FILE_TYPE_COLORS[file_type.to_sym] || '#6b7280'
  end

  def categories_array
    categories || []
  end

  def themes_array
    themes || []
  end

  def collections_array
    collections || []
  end

  private

  def self.ransackable_attributes(auth_object = nil)
    ["author", "id", "name", "supplier_id", "themes", "is_free"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["catalogues", "category", "chapters", "compilations", "grades", "supplier"]
  end
end
