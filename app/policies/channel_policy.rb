class ChannelPolicy < ApplicationPolicy
  attr_reader :user, :channel

  def initialize(user, channel)
    @user = user
    @channel = channel
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.super_admin? || user.editor?
  end

  def update?
    user.super_admin? || user.editor?
  end

  def destroy?
    return false unless user.super_admin? || user.editor?
    true
  end

  def manage_recommended?
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
