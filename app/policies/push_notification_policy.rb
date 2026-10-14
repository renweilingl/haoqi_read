class PushNotificationPolicy < ApplicationPolicy
  attr_reader :user, :push_notification

  def initialize(user, push_notification)
    @user = user
    @push_notification = push_notification
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

  def manage_recommended?
    user.super_admin? || user.operator?
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
