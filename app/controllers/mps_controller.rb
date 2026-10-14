class MpsController < ApplicationController
  before_action :require_login

  def index
    MpsAct.all.find_each do |x|
      SupplementWorker.perform_in(1, x.id)
    end
  end

end
