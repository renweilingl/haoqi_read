# frozen_string_literal: true

module Admin
  class CategorySubsController < ApplicationController
    before_action :require_login
    before_action :set_category
    before_action :set_sub, only: [:edit, :update, :destroy, :update_sn]

    def index
      authorize [:admin, CategorySub], policy_class: Admin::CategorySubPolicy

      if request.xhr?
        items = @category.category_subs.sorted.paginate(page: params[:page], per_page: @per_page).collect {|r|
          {id: r.id,
           name: r.name,
           sn: r.sn,
#           icon_state: r.icon.present?,
#           icon_url: r.icon.present? ? FileMap.new(r.icon, "img").secrity_src : '',
           created_at: r.created_at.strftime('%Y-%m-%d'),
          }
        }
        render json: {data: items, code: 0, count: @category.category_subs.size}
      end
      #@subs = @category.category_subs.sorted.paginate(page: params[:page], per_page: @per_page) 
    end

    def new
      sub = @category.category_subs.order("sn desc").first
      sn = sub.nil? ? 1 : sub.sn + 1

      @sub = @category.category_subs.new(sn: sn)
      authorize [:admin, @sub], policy_class: Admin::CategorySubPolicy
    end

    def create
      @sub = @category.category_subs.new(sub_params)
      authorize [:admin, @sub], policy_class: Admin::CategorySubPolicy

      if @sub.save
        redirect_to admin_category_category_subs_path(@category), notice: '二级分类创建成功'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize [:admin, @sub], policy_class: Admin::CategorySubPolicy
    end

    def update
      authorize [:admin, @sub], policy_class: Admin::CategorySubPolicy

      if @sub.update(sub_params)
        redirect_to admin_category_category_subs_path(@category), notice: '二级分类更新成功'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update_sn
      @sub.update(sn: params[:sn])

      render json: {code: 0}
    end

    def destroy
      authorize [:admin, @sub], policy_class: Admin::CategorySubPolicy

      @sub.destroy
      redirect_to admin_category_category_subs_path(@category), notice: '二级分类删除成功'
    end

    private
    def set_category
      @category = Category.find(params[:category_id])
    end

    def set_sub
      @sub = @category.category_subs.find(params[:id])
    end

    def sub_params
      params.require(:category_sub).permit(
        :name,
        :icon,
        :sn
      )
    end
  end
end
