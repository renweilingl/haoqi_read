class Admin::OptionsController < ApplicationController
  before_action :require_login
  before_action :set_grade
  before_action :set_group

  skip_before_action :verify_authenticity_token, if: -> { request.format.json? }

  def index
    authorize Category

    case params[:content_type]
    when "compilation"
      @title = "选择合辑"
      @name = "compilation_id"
      compilation_ids = @content_group.contents.with_content_type("compilation").pluck(:compilation_id)
      @opts = @grade.compilations.where.not(id: compilation_ids)
    when "book"
      @title = "选择图书"
      @name = "book_id"

      @opts = get_cat_books("图书")
    when "comic"
      @title = "选择漫画"
      @name = "book_id"
      @opts = get_cat_books("漫画")
    when "audio"
      @title = "选择有声"
      @name = "book_id"
      @opts = get_cat_books("有声")
    when "video"
      @title = "选择视频"
      @name = "book_id"
      @opts = get_cat_books("视频")
    when "recommend"
      @title = "选择推荐"
      @name = "recommend_id"
      @opts = Recommend.where(grade_id: params[:grade_id])
    when "rank"
      @title = "选择排行榜"
      @name = "rank_id"
      @opts = Rank.where(grade_id: params[:grade_id])
    when "category_sub"
      @title = "选择二级分类"
      @name = "category_sub_id"
      @opts = CategorySub.all
    end

    render json: { opts: render_to_string(partial: 'opts', layout: false), name: @name }
  end

  private
  def get_cat_books(name)
    cat = Category.find_by_name(name)
    ids = @grade.book_ids

    book_ids = @content_group.contents.with_content_type("book").pluck(:book_id)
#    logger.info "renilin book_ids: #{book_ids}"
    Book.where(id: ids, category_id: cat.id).where.not(id: book_ids)
  end

  def set_grade
    @grade = Grade.find_by_id params[:grade_id]
  end

  def set_group      #分组
    @content_group = ContentGroup.find(params[:content_group_id])
  end

end
