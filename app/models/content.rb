class Content < ApplicationRecord
  audited

  belongs_to :content_group
  belongs_to :compilation, optional: true
  belongs_to :book, optional: true
  belongs_to :author, optional: true
  belongs_to :recommend, optional: true
  belongs_to :rank, optional: true
  belongs_to :category_sub, optional: true

  scope :sorted, -> { order(sn: :asc, id: :desc) }
  scope :with_content_type, ->(content_type) { where(content_type: content_type) }

  enum :content_type, {
    compilation: 'compilation',           # 合辑
    book: 'book', # 单本
    author_display: 'author_display', # 作者显示
    recommend: 'recommend', # 推荐
    rank: 'rank', # 排行榜
    category_sub: 'category_sub', # 二级分类
  }, prefix: true

  CONTENT_TYPES = {
    compilation: '合辑',
    book: '单本',
    author_display: '作者显示',
    recommend: '推荐',
    rank: '排行榜',
    category_sub: '二级分类',
  }.freeze

  def content_type_name
    CONTENT_TYPES[content_type.to_sym] || content_type
  end


  def display_img_url
    if content_group.group_type == "multi_images" || content_group.group_type == "sub_recommend"
      img_url
    else
      if content_type == "compilation"
        compilation.banner_image_url
      elsif content_type == "book"
        book.cover_image_url
      elsif content_type == "author_display"
        author.head_img
      end
    end
  end

  def content_name
    case content_type
    when "compilation"
      compilation.name
    when "book"
      book.name
    when "author_display"
      author.name
    when "recommend" 
      recommend.name
    when "rank"
      rank.name
    when "category_sub"
      category_sub.name
    end
  end
end
