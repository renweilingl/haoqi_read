class HeadImgPolicy < ApplicationPolicy
  attr_reader :user, :head_img

  def initialize(user, head_img)
    @user = user
    @head_img = head_img
  end

  def index?
    user.super_admin?
  end

  def new?
    user.super_admin?
  end

  def create?
    user.super_admin?
  end

  def edit?
    user.super_admin?
  end

  def create?
    user.super_admin?
  end

  def update?
    user.super_admin?
  end

  def destroy?
    return false unless user.super_admin? || user.editor?
    true
  end

  class Scope < Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.active
      end
    end
  end
end
