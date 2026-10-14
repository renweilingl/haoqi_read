class RankContent < ApplicationRecord
  audited

  belongs_to :rank
  belongs_to :compilation, optional: true
  belongs_to :book, optional: true

  enum :content_type, {
    compilation: 'compilation',           # 合辑
    book: 'book', # 单本
  }, prefix: true

  CONTENT_TYPES = {
    compilation: '合辑',
    book: '单本',
  }.freeze

  def content_type_name
    CONTENT_TYPES[content_type.to_sym] || content_type
  end

  def content_name
    if content_type == "compilation"
      compilation.name
    elsif content_type == "book"
      book.name
    end
  end
end
