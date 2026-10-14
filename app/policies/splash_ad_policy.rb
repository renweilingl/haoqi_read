class SplashAdPolicy < ApplicationPolicy
  attr_reader :user, :splash_ad

  def initialize(user, splash_ad)
    @user = user
    @splash_ad = splash_ad
  end

  def index?
    user.super_admin? || user.operator?
  end

  def show?
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

  def publish?
    user.super_admin? || user.editor?
  end

  def disable?
    user.super_admin? || user.editor?
  end

  def enable?
    user.super_admin? || user.editor?
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
