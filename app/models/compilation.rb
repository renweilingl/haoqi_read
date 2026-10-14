# frozen_string_literal: true

class Compilation < ApplicationRecord
  audited
  has_and_belongs_to_many :grades, join_table: :compilation_grades
  has_and_belongs_to_many :categories, join_table: :compilation_categories
  has_and_belongs_to_many :books, join_table: :compilation_books

  has_many :contents, dependent: :destroy
  has_many :rank_contents, dependent: :destroy

  has_many :splash_ads

  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { case_sensitive: false }
  validates :editor_recommendation, length: { maximum: 15 }, allow_blank: true

  enum :serialize_state, {
    serializing: 'serializing',          
    completed: 'completed',
  }, prefix: true

  SERIAL_STATE_NAMES = {
    serializing: '连载中',
    completed: '已完结'
  }.freeze


  def serialize_state_name
    SERIAL_STATE_NAMES[serialize_state.to_sym] || serialize_state
  end

  def tags_array
    tags || []
  end

  # 封面完整性检查
  def covers_complete?
    landscape_cover_url.present? && portrait_cover_url.present? && square_cover_url.present?
  end

  # 获取主封面
  def main_cover_url
    landscape_cover_url || banner_image_url
  end

  def offline!
    update(status: :offline)
  end

  def toggle_status
    if draft?
      publish!
      '已上线'
    elsif published?
      offline!
      '已下线'
    else
      update(status: :draft)
      '已恢复为草稿'
    end
  end

  def self.cover_specifications
    {
      banner: { width: 1500, height: 932, max_size: 500, unit: 'KB', desc: '合辑banner' },
      landscape: { width: 1125, height: 540, max_size: 500, unit: 'KB', desc: '横图封面' },
      portrait: { width: 600, height: 768, max_size: 300, unit: 'KB', desc: '长方形封面' },
      square: { width: 600, height: 600, max_size: 300, unit: 'KB', desc: '正方形封面' }
    }
  end

  private

  #def validate_age_range
  #  if min_age.present? && max_age.present? && min_age > max_age
  #    errors.add(:min_age, '最小年龄不能大于最大年龄')
  #  end
  #end

  #def validate_age_groups
  #  if age_groups.present? && age_groups.length < 1
  #    errors.add(:age_groups, '请至少选择一个年龄段')
  #  end
  #end

  def self.ransackable_attributes(auth_object = nil)
    ["author", "created_at", "description", "editor_recommendation", "first_category_id", "id", "id_value", "intro_image_name", "intro_image_url", "landscape_cover_name", "landscape_cover_url", "name", "portrait_cover_name", "portrait_cover_url", "publisher", "square_cover_name", "square_cover_url", "tags", "total_count", "updated_at"]
  end
end
