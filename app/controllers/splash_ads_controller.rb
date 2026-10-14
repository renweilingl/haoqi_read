require 'active_support/time_with_zone'
class SplashAdsController < ApplicationController
  before_action :require_login
  before_action :set_splash_ad, only: [:show, :edit, :update, :destroy, :publish, :disable, :enable]
  
  def index
    authorize :splash_ad, :index?
    
    @per_page = params[:per_page] || 20

    @q = SplashAd.ransack(params[:q])
    @splash_ads = @q.result.ordered.paginate(page: params[:page], per_page: @per_page)
  end
  
  def show
    authorize @splash_ad
    @stats = {
      send_count: @splash_ad.send_count,
      click_count: @splash_ad.click_count,
      #delivery_rate: @splash_ad.delivery_rate_display,
      click_rate: @splash_ad.click_rate_display
    }
  end
  
  def new
    @splash_ad = SplashAd.new(
      push_scope: :all_users,
      push_mode: :first_open_daily,
      link_type: :single_book,
      status: :draft
    )
    authorize @splash_ad

    load_associations
  end
  
  def create
    @splash_ad = SplashAd.new(splash_ad_params)
    authorize @splash_ad

    if @splash_ad.save
      flash[:notice] = "开屏广告创建成功！"
      redirect_to :splash_ads
    else
      load_associations
      flash.now[:alert] = "开屏广告创建失败：#{@splash_ad.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    authorize @splash_ad
    load_associations
  end
  
  def update
    authorize @splash_ad
    
    if @splash_ad.update!(splash_ad_params)
      redirect_to splash_ads_path, notice: '开屏广告更新成功。'
    else
      load_associations
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    authorize @splash_ad
    @splash_ad.update(status: :deleted)
    
    render json: {success: true, status: @splash_ad.status}
  end
  
  def publish
    authorize @splash_ad
    
    @splash_ad.update!(status: :active)
    render json: {success: true, status: @splash_ad.status}
  end
  
  def disable
    authorize @splash_ad
    @splash_ad.disable!
    
    render json: {success: true, status: @splash_ad.status}
  end
  
  def enable
    authorize @splash_ad
    @splash_ad.enable!
    
    render json: {success: true, status: @splash_ad.status}
  end
  
  def books_options
    authorize :splash_ad, :index?
    
    query = params[:q].to_s.strip
    books = Book.where
                .where('name LIKE ?', "%#{query}%")
                .limit(20)
                .select(:id, :name)
    
    render json: books.map { |b| { id: b.id, name: b.name } }
  end
  
  def categories_options
    authorize :splash_ad, :index?
    
    categories = Category.where
                         .select(:id, :name)
    
    render json: categories.map { |c| { id: c.id, name: c.name } }
  end
  
  private
  
  def set_splash_ad
    @splash_ad = SplashAd.find(params[:id])
  end
  
  def splash_ad_params
    params.require(:splash_ad).permit(
      :ad_type, :image_url, :pad_image_url,
      :link_type, :link_url, :book_id, :compilation_id,
      :push_scope,
      :push_mode, :scheduled_at,
      :start_time, :end_time,
      :status,
      :grade_ids => []
    )
  end
  
  def load_associations
    @books = Book.all.order(:name)
    @categories = Category.all.order(:name)
  end
  
  def calculate_avg_delivery_rate
    ads = SplashAd.where.not(send_count: 0)
    return 0 if ads.empty?
    
    total_rate = ads.sum(:delivery_rate)
    (total_rate / ads.count * 100).round(2)
  end
end
