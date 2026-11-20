class Admin::BooksController < ApplicationController
  include PictureBooksHelper
  before_action :require_login
  before_action :get_resource, only: %i[edit update destroy contents multimedia batch_clean_contents correction update_correction]

  def index
    authorize Book
    @per_page = params[:per_page] || 20

    category_ids = Category.where(name: ["绘本"]).pluck(:id)
    @q = Book.where(category_id: category_ids).ransack(params[:q])
    @books = @q.result.order("id asc").paginate(page: params[:page], per_page: @per_page)

    @suppliers = Supplier.all
  end

  def new
    @book = Book.new(is_published: true)
    cat = Category.find_by(name: "绘本")
    @book.category_id = cat.id
    authorize @book
    @suppliers = Supplier.all
  end

  def create
    @book = Book.new(book_params)
    authorize @book
    @suppliers = Supplier.all

    if @book.save
      redirect_to :admin_books, notice: '绘本创建成功'
    else
      render :new
    end
  end

  def edit
    authorize @book
    @suppliers = Supplier.all
  end

  def update
    @book.update(book_params)
    identify_time(@book.id)
    redirect_to :action => :index
  end

  def contents
    if request.xhr?                                                              
      resource = @book.book_contents
      items = resource.order("sn asc").paginate(page: params[:page], per_page: params[:limit]).collect {|r|                
        {id: r.id,                                                               
         name: r.name,                                                           
         sn: r.sn,                                                               
         img_path: FileMap.new(r.img_path, "img").secrity_src,
         start_at: r.start_at,                                                   
         deal_at: r.deal_at                                                      
        }                                                                        
      }                                                                          
      render json: {data: items, code: 0, count: resource.size}                  
    end
  end

  def correction
    @book_pages = @book.picture_book_pages.ordered
    @book_page = @book_pages.detect { |page| page.page_number.to_s == params[:page_number].to_s } || @book_pages.first
    return if @book_page.nil?

    @subtitle_payload = @book_page.subtitle_payload
    @subtitle_lines = @book_page.subtitle_lines
    @page_meta = @subtitle_payload.is_a?(Hash) ? @subtitle_payload : {}

    # 页图存在私有 OSS 桶里，裸链接会 403，签名后浏览器才能加载
    page_image = @book_page.image_url.presence || @page_meta["image"]
    @page_image = page_image.present? ? FileMap.new(page_image.to_s, "img").secrity_src : nil
    @token_keys = token_keys_of(@subtitle_lines)

    # char_times 是整页逐字播放时间，按 token 出现顺序与文字一一对应
    @char_times = @page_meta["char_times"].is_a?(Array) ? @page_meta["char_times"] : nil
    @token_count = @subtitle_lines.sum { |line| line.is_a?(Hash) ? Array.wrap(line["tokens"]).size : 0 }
    @inline_char_times = @char_times.present? && @char_times.size == @token_count
  end

  def update_correction
    @book_page = @book.picture_book_pages.find_by(page_number: params[:page_number])
    return render json: {code: 1, msg: "页面不存在"} if @book_page.nil?

    new_lines = normalized_lines(params[:lines])
    return render json: {code: 1, msg: "lines 格式不正确"} if new_lines.nil?

    char_times = nil
    if params[:char_times].present?
      char_times = normalized_char_times(params[:char_times])
      return render json: {code: 1, msg: "char_times 必须是一组数字"} if char_times.nil?

      # Rails 解析 JSON body 时会丢掉数组里的 null，项数变少会让后面每个字的播放时间错位
      saved_char_times = saved_char_times_of(@book_page)
      if saved_char_times && char_times.size != saved_char_times.size
        return render json: {code: 1, msg: "char_times 项数不能变（原有 #{saved_char_times.size} 项，收到 #{char_times.size} 项）"}
      end
    end

    @book_page.update_subtitle!(new_lines, char_times: char_times)

    # 提取 keywords 并更新到数据库字段
    keywords = extract_keywords(new_lines)
    @book_page.update(keywords: keywords.presence)

    # 调用 haoqi_voicebook API 触发 JSON 重新生成
    result = VoicebookRegenerateService.call(@book.id)
    Rails.logger.info "[VoicebookRegenerate] book_id=#{@book.id}, result=#{result.inspect}"

    render json: {code: 0}
  rescue ActiveRecord::RecordInvalid => e
    render json: {code: 1, msg: e.message}
  end

  def batch_clean_contents
    @book.book_contents.destroy_all
    redirect_to contents_admin_book_path(@book)
  end

  def multimedia
    file = params[:file]
    tmp_file_path = file.tempfile.path
    mime = `file --brief --mime-type "#{tmp_file_path}"`.strip

    uuid = SecureRandom.uuid.delete('-')
    oss_path = AliyunOss.instance.put(uuid, File.open(tmp_file_path), {'content_type': mime})

    @book.book_contents.create(img_path: oss_path, name: file.original_filename)

    auto_sort_contents(@book.id)
    render json: {code: 0}
  end

  def destroy
    #redirect_to admin_compilation_books_path(@compilation)
  end

  private
  def get_resource
    @book = Book.find_by_id params[:id]
  end

  # 所有 token 出现过的字段（ch/py/b...），按出现顺序取并集，用于渲染编辑列。
  # kw 是重点字标记，页面上有专门的勾选框，不当普通文本字段渲染，避免同一个值两处编辑。
  def token_keys_of(lines)
    keys = []
    lines.each do |line|
      next unless line.is_a?(Hash)

      Array.wrap(line["tokens"]).each do |token|
        keys |= token.keys if token.is_a?(Hash)
      end
    end
    keys - ["kw"]
  end

  # 只接受「行数组，每行是对象，tokens 是数组」这一种结构，其余返回 nil 由调用方报错
  def normalized_lines(param)
    return nil unless param.is_a?(Array)

    param.map do |line|
      line = line.to_unsafe_h if line.is_a?(ActionController::Parameters)
      return nil unless line.is_a?(Hash)
      return nil if line.key?("tokens") && !line["tokens"].is_a?(Array)

      line
    end
  end

  # 逐字播放时间：只接受数组，元素必须能转成数字；原本就是数字的保持原类型（不强行转 Float）
  def normalized_char_times(param)
    return nil unless param.is_a?(Array)

    param.map do |value|
      next value if value.is_a?(Numeric)

      begin
        Float(value)
      rescue ArgumentError, TypeError
        return nil
      end
    end
  end

  # 库已存的逐字播放时间；这一页没有 char_times 时返回 nil
  def saved_char_times_of(book_page)
    payload = book_page.subtitle_payload
    return nil unless payload.is_a?(Hash)

    payload["char_times"].is_a?(Array) ? payload["char_times"] : nil
  end

  # 从 lines 中提取所有 kw=1 的 token 的 ch 字段，去重后返回数组
  def extract_keywords(lines)
    keywords = []
    lines.each do |line|
      next unless line.is_a?(Hash)

      Array.wrap(line["tokens"]).each do |token|
        next unless token.is_a?(Hash) && token["kw"] == 1 && token["ch"].present?

        keywords << token["ch"]
      end
    end
    keywords.uniq
  end

  def book_params
    params.require(:book).permit(
      :name,
      :cover_image_url,
      :supplier_id,
      :category_id,
      :book_level_id,
      :author_id,
      :file_url,
      :file_name,
      :file_type,
      :is_free,
      :is_published,
      :time_line,
      :content_description,
      :grade_ids => [],
      :category_sub_ids => []
    )
  end
end
