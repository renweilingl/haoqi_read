# frozen_string_literal: true

module Admin
  class ContentsController < ApplicationController
    before_action :require_login
    before_action :set_grade
    before_action :set_recommend
    before_action :set_group
    before_action :set_content, only: [:edit, :update, :destroy]

    def new
      if @content_group.group_type == "sub_recommend" && @content_group.contents.count >= 10 
        flash[:notice] = "当前类型只允许添加8个内容"
        return redirect_to admin_grade_recommend_content_group_path(@grade, @recommend, @content_group)
      end

      if "single_row_vertical_column" == @content_group.group_type && @content_group.contents.count >= 20 
        flash[:notice] = "当前类型只允许添加20个内容"
        return redirect_to admin_grade_recommend_content_group_path(@grade, @recommend, @content_group)
      end

      content = @content_group.contents.order("sn desc").first
      sn = content.nil? ? 1 : content.sn + 1
      @content = @content_group.contents.new(sn: sn)

      if @content_group.group_type == "author_display"
        @content.content_type = "author_display"
      elsif @content_group.group_type == "sub_recommend"  #默认选择推荐
        @content.content_type = "recommend"
        recommend_ids = @content_group.contents.with_content_type("recommend").pluck(:recommend_id)
        @recommends = Recommend.where(grade_id: @grade.id).where.not(id: recommend_ids)
      else  #默认选择合辑
        @content.content_type = "compilation"
        compilation_ids = @content_group.contents.with_content_type("compilation").pluck(:compilation_id)
        @compilations = @grade.compilations.where.not(id: compilation_ids)
      end

      authorize [:admin, @content], policy_class: Admin::ContentPolicy
    end

    def create
      @content = @content_group.contents.new(content_params)
      authorize [:admin, @content], policy_class: Admin::ContentPolicy

      if params[:content_type].present?
        if "compilation" == params[:content_type]
          @content.content_type = "compilation"
        else
          @content.content_type = "book"
        end
      end

      if @content.save
        redirect_to admin_grade_recommend_content_group_path(@grade, @recommend, @content_group), notice: '内容创建成功'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize [:admin, @content], policy_class: Admin::ContentPolicy

      if @content.content_type == "compilation"  #合辑
        compilation_ids = @content_group.contents.with_content_type("compilation").pluck(:compilation_id)
        @compilations = @grade.compilations.where.not(id: compilation_ids)
      elsif @content.content_type == "recommend"  #推荐
        @recommends = Recommend.where(grade_id: @grade.id)
      elsif @content.content_type == "book"
        book_ids = @content_group.contents.with_content_type("book").pluck(:book_id) - [@content.book_id]
        @books = Book.where(id: @grade.book_ids, category_id: @content.book.category_id).where.not(id: book_ids) || []
      end
    end

    def update
      authorize [:admin, @content], policy_class: Admin::ContentPolicy

      if @content.update(content_params)
        redirect_to admin_grade_recommend_content_group_path(@grade, @recommend, @content_group), notice: '内容更新成功'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize [:admin, @content], policy_class: Admin::ContentPolicy

      @content.destroy
      redirect_to admin_grade_recommend_content_group_path(@grade, @recommend, @content_group), notice: '内容删除成功'
    end

    private
    def set_grade      #年级
      @grade = Grade.find(params[:grade_id])
    end

    def set_recommend  #推荐
      @recommend = Recommend.find(params[:recommend_id])
    end

    def set_group      #分组
      @content_group = ContentGroup.find(params[:content_group_id])
    end

    def set_content
      @content = Content.find(params[:id])
    end

    def content_params
      params.require(:content).permit(
        :content_type,
        :img_url,
        :compilation_id,
        :book_id,
        :recommend_id,
        :author_id,
        :recommend_id,
        :name,
        :color,
        :rank_id,
        :category_sub_id
      ).merge(
        sn: params.dig(:content, :sn).to_i
      )
    end
  end
end
