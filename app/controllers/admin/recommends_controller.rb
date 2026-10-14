# frozen_string_literal: true

module Admin
  class RecommendsController < ApplicationController
    before_action :require_login
    before_action :set_grade
    before_action :set_recommend, only: [:show, :edit, :update, :destroy, :toggle_status]

    def index
      authorize [:admin, Recommend], policy_class: Admin::RecommendPolicy

      @recommends = @grade.recommends.sorted.paginate(page: params[:page], per_page: 15)
    end

    def show
      authorize [:admin, @recommend], policy_class: Admin::RecommendPolicy
    end

    def new
      @recommend = @grade.recommends.new
      authorize [:admin, @recommend], policy_class: Admin::RecommendPolicy
    end

    def create
      @recommend = @grade.recommends.new(recommend_params)
      authorize [:admin, @recommend], policy_class: Admin::RecommendPolicy

      if @recommend.save
        redirect_to admin_grade_recommends_path(@grade), notice: '推荐内容创建成功'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize [:admin, @recommend], policy_class: Admin::RecommendPolicy
    end

    def update
      authorize [:admin, @recommend], policy_class: Admin::RecommendPolicy

      if @recommend.update(recommend_params)
        redirect_to admin_grade_recommends_path(@grade), notice: '推荐内容更新成功'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize [:admin, @recommend], policy_class: Admin::RecommendPolicy

      @recommend.destroy
      redirect_to admin_grade_recommends_path(@grade), notice: '推荐内容删除成功'
    end

    def toggle_status
      authorize [:admin, @recommend], policy_class: Admin::RecommendPolicy

      @recommend.update(status: !@recommend.status)
      redirect_to admin_grade_recommends_path(@grade), notice: @recommend.status ? '已发布' : '已下架'
    end

    private

    def set_grade
      @grade = Grade.find(params[:grade_id])
    end

    def set_recommend
      @recommend = @grade.recommends.find(params[:id])
    end

    def recommend_params
      params.require(:recommend).permit(
        :name, :color, :status
      ).merge(
        sn: params.dig(:recommend, :sn).to_i
      )
    end
  end
end
