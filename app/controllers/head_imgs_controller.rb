class HeadImgsController < ApplicationController
  before_action :require_login
  before_action :set_head_img, only: [:edit, :update, :destroy]

  def index
    authorize HeadImg

    @per_page = params[:per_page] || 20
    @q = HeadImg.ransack(params[:q])
    @head_imgs = @q.result.paginate(page: params[:page], per_page: @per_page)
  end

  def new
    authorize HeadImg

    @head_img = HeadImg.new(is_vip: false)
  end

  def create
    authorize HeadImg

    @head_img = HeadImg.new(head_img_params)

    if @head_img.save
      redirect_to :head_imgs, notice: '头像创建成功'
    else
      flash.now[:alert] = "头像创建失败：#{@head_img.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @head_img
  end

  def update
    authorize @head_img

   if @head_img.update(book_params)
      redirect_to :head_imgs, notice: '头像更新成功'
    else
      flash.now[:alert] = "头像更新失败：#{@head_img.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  def destroy
    authorize @head_img

    @head_img.destroy

    redirect_to :head_imgs, notice: '头像删除成功'
  end

  private
  def set_head_img
    @head_img = HeadImg.find(params[:id])
  end

  def head_img_params
    params.require(:head_img).permit(:is_vip, :img_url)
  end

end
