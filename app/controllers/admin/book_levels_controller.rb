class Admin::BookLevelsController < ApplicationController
  before_action :require_login
  before_action :set_book_level, only: [:show, :edit, :update, :destroy]
  
  def index
    authorize BookLevel
    @book_levels = BookLevel.all.paginate(page: params[:page], per_page: @per_page)
  end
  
  def show
    authorize @book_level
  end
  
  def new
    @book_level = BookLevel.new
    authorize @book_level
  end
  
  def create
    @book_level = BookLevel.new(book_level_params)
    authorize @book_level
    
    if @book_level.save
      flash[:success] = '图书等级创建成功'
      redirect_to admin_book_levels_path
    else
      flash[:error] = @book_level.errors.full_messages.join(', ')
      render :new
    end
  end
  
  def edit
    authorize @book_level
  end
  
  def update
    authorize @book_level
    
    if @book_level.update(book_level_params)
      flash[:success] = '图书等级更新成功'
      redirect_to admin_book_levels_path
    else
      flash[:error] = @book_level.errors.full_messages.join(', ')
      render :edit
    end
  end
  
  def destroy
    authorize @book_level
    
    if @book_level.destroy
      flash[:success] = '图书等级删除成功'
    else
      flash[:error] = @book_level.errors.full_messages.join(', ')
    end
    redirect_to admin_book_levels_path
  end
  
  private
  
  def set_book_level
    @book_level = BookLevel.find(params[:id])
  end
  
  def book_level_params
    params.require(:book_level).permit(:name, :sn)
  end
end
