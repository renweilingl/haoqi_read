class Admin::ChaptersController < ApplicationController
  before_action :require_login
  before_action :set_book

  def index
    authorize Book

    if request.xhr?
      items = @book.chapters.order("sn asc").paginate(page: params[:page], per_page: params[:limit]).collect {|r|
        {id: r.id,
         book_id: r.book_id,
         name: r.name,
         content_file_name: r.content_file_name,
         sn: r.sn,
         is_free: r.is_free,
         is_published: r.is_published,
         created_at: r.created_at.strftime('%Y-%m-%d'),
        }
      }
      render json: {data: items, code: 0, count: @book.chapters.size}
    end
  end

  def new
    authorize @book

    chapter = @book.chapters.order("sn desc").first
    sn = chapter.nil? ? 1 : chapter.sn + 1

    @chapter = @book.chapters.new(is_published: true, sn: sn)
  end

  def create
    authorize @book

    @chapter = @book.chapters.new(chapter_params)

    if @chapter.save
      redirect_to admin_media_book_chapters_path(@book), notice: '内容创建成功'
    else
      flash[:error] = @chapter.errors.full_messages.join(', ')
      render :new
    end
  end

  def batch_new
    authorize @book

    @chapter = @book.chapters.new
  end

  def batch_add
    authorize @book

    chapter = @book.chapters.order("sn desc").first
    sn = chapter.nil? ? 1 : chapter.sn + 1

    publish_date = params[:chapter][:publish_date]
    params[:content_file_url].each_with_index do |file_url, idx|
      @book.chapters.create!(publish_date: publish_date,
                            name: params[:content_file_name][idx],
                            content_file_url: file_url,
                            content_file_type: params[:content_file_type][idx],
                            duration: params[:duration][idx],
                            is_free: false,
                            is_published: true,
                            sn: sn + idx)
    end

    redirect_to admin_media_book_chapters_path(@book), notice: '内容创建成功'
  end

  def edit
    authorize @book

    @chapter = @book.chapters.find(params[:id])
  end

  def update
    authorize @book

    chapter = @book.chapters.find(params[:id])
    chapter.update(chapter_params)

    redirect_to admin_media_book_chapters_path(@book), notice: '内容修改成功'
  end

  def update_sn
    @book.chapters.find(params[:id]).update(sn: params[:sn])

    render json: {code: 0}
  end

  def destroy
    authorize @book

    @chapter  = Chapter.find(params[:id])

    @chapter.destroy
    flash[:notice] = "内容删除成功！"

    redirect_to admin_media_book_chapters_path(@book)
  end

  def batch_free
    @book.chapters.where(id: params[:ids]).update_all(is_free: true)
    render json: {code: 0}
  end

  def batch_unfree
    @book.chapters.where(id: params[:ids]).update_all(is_free: false)
    render json: {code: 0}
  end

  private

  def set_book
    @book = Book.find(params[:media_book_id])
  end

  def chapter_params
    params.require(:chapter).permit(
      :name, :sn, :is_published, :is_free, :duration, :publish_date,
      :content_file_url, :content_file_name, :content_file_type
    ).tap do |whitelisted|
      # Auto-extract duration from media file if not manually provided
      if whitelisted[:content_file_url].present? && whitelisted[:duration].blank?
        local_path = find_local_media_path(whitelisted[:content_file_url])
        if local_path
          whitelisted[:duration] = MediaDurationService.extract_duration(local_path)
        end
      end
    end
  end

  # Find the local temp file path from the OSS URL
  def find_local_media_path(file_url)
    filename = File.basename(URI.parse(file_url).path)
    temp_path = Rails.root.join('tmp', 'uploads', filename).to_s
    File.exist?(temp_path) ? temp_path : nil
  end

end
