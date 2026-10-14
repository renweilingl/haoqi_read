class Admin::SuppliersController < ApplicationController
  before_action :require_login
  before_action :set_supplier, only: [:show, :edit, :update, :destroy]

  def index
    authorize Supplier

    @per_page = params[:per_page] || 20

    @q = Supplier.ransack(params[:q])
    @suppliers = @q.result.paginate(page: params[:page], per_page: @per_page)

    respond_to do |format|
      format.html
      format.json { render json: {
        success: true,
        categories: @suppliers.map(&:as_json),
        pagination: {
          current_page: @suppliers.current_page,
          total_pages: @suppliers.total_pages,
          total_count: @suppliers.total_entries,
          per_page: @suppliers.per_page
        }
      }}
    end
  end

  def new
    @supplier = Supplier.new
  end

  def create
    @supplier = Supplier.new(supplier_params)

    if @supplier.save
      redirect_to admin_suppliers_path, notice: '出版社创建成功'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @supplier.update(supplier_params)
      redirect_to admin_supplier_path(@supplier), notice: '出版社更新成功'
    else
      render :edit
    end
  end

  def destroy
    if @supplier.destroy
      redirect_to admin_suppliers_path, notice: '出版社删除成功'
    else
      redirect_to admin_suppliers_path, alert: '删除失败'
    end
  end


  private
  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(
      :name
    )
  end
end
