class Admin::BooksController < ApplicationController
  include PictureBooksHelper
  before_action :require_login
  before_action :get_resource, only: %i[edit update destroy contents multimedia batch_clean_contents]

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
  end

  def update
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

  def batch_clean_contents
    @book.book_contents.destroy_all
    redirect_to contents_admin_book_path(@book)
  end

  def multimedia
    file = params[:file]
    tmp_file_path = file.tempfile.path
    mime = `file --brief --mime-type "#{tmp_file_path}"`.strip

    uuid = SecureRandom.uuid.delete('-')
    oss_path = AliyunOss.instance.put(uuid, File.open(file.path), {'content_type': mime})

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
