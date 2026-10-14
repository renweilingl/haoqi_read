class Statistic::GradeReportsController < ApplicationController
  before_action :require_login

  def index
    @items = []
    AppUser.all.group_by(&:grade_id).each do |r|
      grade = Grade.find_by_id r[0]
      @items << [grade.name, r[1].count]
    end
  end

end
