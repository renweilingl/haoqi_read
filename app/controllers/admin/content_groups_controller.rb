# frozen_string_literal: true

module Admin
  class ContentGroupsController < ApplicationController
    before_action :require_login

    before_action :set_grade
    before_action :set_recommend
    before_action :set_group, only: [:show, :edit, :update, :destroy]

    def index
      authorize [:admin, ContentGroup], policy_class: Admin::ContentGroupPolicy

      @content_groups = @recommend.content_groups.sorted.paginate(page: params[:page], per_page: 15)
    end

    def show
      authorize [:admin, @content_group], policy_class: Admin::ContentGroupPolicy
    end

    def new
      content_group = @recommend.content_groups.order("sn desc").first

      sn = content_group.nil? ? 1 : content_group.sn + 1

      logger.info "renweilin: #{@recommend.content_groups.count}, #{sn}, #{content_group.as_json}"

      @content_group = @recommend.content_groups.new(sn: sn)
      authorize [:admin, @content_group], policy_class: Admin::ContentGroupPolicy
    end

    def create
      @content_group = @recommend.content_groups.new(group_params)
      authorize [:admin, @content_group], policy_class: Admin::ContentGroupPolicy

      if @content_group.save
        redirect_to admin_grade_recommend_content_groups_path(@grade, @recommend), notice: '内容分组创建成功'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize [:admin, @content_group], policy_class: Admin::ContentGroupPolicy
    end

    def update
      authorize [:admin, @content_group], policy_class: Admin::ContentGroupPolicy

      if @content_group.update(group_params)
        redirect_to admin_grade_recommend_content_groups_path(@grade, @recommend),notice: '内容分组更新成功'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize [:admin, @content_group], policy_class: Admin::ContentGroupPolicy

      @content_group.destroy
      redirect_to admin_grade_recommend_content_groups_path(@grade, @recommend),notice: '内容分组删除成功'
    end

    private
    def set_grade
      @grade = Grade.find(params[:grade_id])
    end

    def set_recommend
      @recommend = Recommend.find(params[:recommend_id])
    end

    def set_group
      @content_group = @recommend.content_groups.find(params[:id])
    end

    def group_params
      params.require(:content_group).permit(
        :name,
        :group_type
      ).merge(
        sn: params.dig(:content_group, :sn).to_i
      )
    end
  end
end
