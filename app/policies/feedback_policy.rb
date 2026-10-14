class FeedbackPolicy < ApplicationPolicy
  attr_reader :user, :feedback

  def initialize(user, feedback)
    @user = user
    @feedback = feedback
  end

  def index?
    user.super_admin? || user.operator?
  end

  def new?
    user.super_admin? || user.operator?
  end

  def create?
    user.super_admin? || user.operator?
  end

  def edit?
    user.super_admin? || user.operator?
  end

  def create?
    user.super_admin? || user.operator?
  end

  def update?
    user.super_admin? || user.operator?
  end

  def destroy?
    return false unless user.super_admin? || user.operator?
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
