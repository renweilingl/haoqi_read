class RanksController < ApplicationController
  before_action :require_login
  before_action :set_grade
  before_action :set_rank, only: [:edit, :update, :destroy]

  def index
    authorize Rank

    @per_page = params[:per_page] || 20
    @q = Rank.where(grade_id: @grade.id).ransack(params[:q])
    @ranks = @q.result.order("sn asc") #.paginate(page: params[:page], per_page: @per_page)
  end

  def new
    rank = @grade.ranks.order("sn desc").first
    sn = rank.nil? ? 1 : rank.sn + 1

    @rank = @grade.ranks.new(sn: sn, category_id: 1)
    authorize @rank
  end

  def create
    @rank = @grade.ranks.new(rank_params)
    authorize @rank

    if @rank.save!
      flash[:success] = '排行榜创建成功'
      redirect_to grade_ranks_path(@grade)
    else
      flash[:error] = @rank.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    authorize @rank
  end

  def update
    authorize @rank

    if @rank.update(rank_params)
      flash[:success] = '排行榜等级更新成功'
      redirect_to grade_ranks_path(@grade)
    else
      flash[:error] = @rank.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    authorize @rank
    @rank.destroy

    flash[:success] = '排行榜删除成功'
    redirect_to grade_ranks_path(@grade)
  end

  private
  def set_grade
    @grade = Grade.find(params[:grade_id])
  end

  def set_rank
    @rank = Rank.find(params[:id])
  end

  def rank_params
    params.require(:rank).permit(:name, :sn, :category_id)
  end
end
