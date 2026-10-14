class GradesController < ApplicationController
  before_action :require_login

  def index
    authorize Grade
    @grades = Grade.all.order("id asc")
  end

  def options
    if params[:content_type] == "compilation"
      @title = "选择合辑"
      @name = "compilation_id"
      @opts = Compilation.all
    elsif params[:content_type] == "book"
      @title = "选择单本"
      @name = "book_id"
      @opts = Book.all
    end

    render json: { opts: render_to_string(partial: 'opts', layout: false), name: @name }
  end

end
