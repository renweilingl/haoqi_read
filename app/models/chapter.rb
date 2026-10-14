# frozen_string_literal: true

class Chapter < ApplicationRecord
  audited
  belongs_to :book

  # 内容文件类型
  FILE_TYPES = {
    mp3: 'mp3',
    mp4: 'mp4',
    wav: 'wav',
    mov: 'mov',
  }.freeze

  FILE_TYPE_NAMES = {
    mp3: '有声',
    mp4: '视频',
    wav: '有声',
    mov: '视频',
  }.freeze

  FILE_TYPE_ICONS = {
    mp3: 'layui-icon-headset',
    mp4: 'layui-icon-video',
    wav: 'layui-icon-headset',
    mov: 'layui-icon-video',
  }.freeze

  FILE_TYPE_COLORS = {
    mp3: '#8b5cf6',
    mp4: '#3b82f6',
    wav: '#8b5cf6',
    mov: '#3b82f6',
  }.freeze

  # 验证
  validates :name, presence: true, length: { maximum: 100 }
  validates :content_file_type, inclusion: { in: FILE_TYPES.values }, allow_blank: true

  # 实例方法
  def file_type_name
    FILE_TYPE_NAMES[content_file_type.to_sym] || content_file_type
  end

  def file_type_icon
    FILE_TYPE_ICONS[content_file_type.to_sym] || 'layui-icon-file'
  end

  def file_type_color
    FILE_TYPE_COLORS[content_file_type.to_sym] || '#6b7280'
  end

  def publish!
    update(is_published: true)
  end

  def unpublish!
    update(is_published: false)
  end

  def toggle_publish
    if is_published?
      unpublish!
      '已下线'
    else
      publish!
      '已上线'
    end
  end

  # 切换免费状态
  def toggle_free
    update(is_free: !is_free)
    is_free? ? '已设为免费' : '已设为付费'
  end
end
