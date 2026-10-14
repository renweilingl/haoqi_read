class Admin::AuthorsController < ApplicationController
  before_action :require_login
  before_action :set_author, only: [:edit, :update, :destroy]

  def index
    authorize Author

    @per_page = params[:per_page] || 20

    @q = Author.ransack(params[:q])
    @authors = @q.result.paginate(page: params[:page], per_page: @per_page)
  end

  def new
    @author = Author.new
  end

  def create
    @author = Author.new(author_params)

    if @author.save
      redirect_to :admin_authors, notice: '作者创建成功'
    else
      render :new
    end
  end

  def batch_new
    authorize Author
  end

  def batch_add
    authorize Author

    doc = SimpleXlsxReader.open(params[:file].tempfile.path)
    doc.sheets.first.rows.each_with_index do |r, i|
      begin
        next if i == 0

        next if r[0].blank?

        name = r[0].strip
        if Author.where(name: name).empty?
          Author.create(name: name)
        end
      rescue StandardError => e
        logger.info "batch import rooms err: #{e}"
      end
    end
  end

  def edit
  end

  def update
    if @author.update(author_params)
      redirect_to admin_authors_path, notice: '作者更新成功'
    else
      render :edit
    end
  end

  def destroy
    if @author.destroy
      redirect_to admin_authors_path, notice: '作者删除成功'
    else
      redirect_to admin_suppliers_path, alert: '删除失败'
    end
  end

  private
  def set_author
    @author = Author.find(params[:id])
  end

  def author_params
    params.require(:author).permit(
      :name,
      :head_img
    )
  end
end
