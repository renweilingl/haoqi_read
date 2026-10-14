class AuthorPolicy < ApplicationPolicy
  attr_reader :user, :supplier

  def initialize(user, supplier)
    @user = user
    @category = supplier
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

  def batch_new?
    user.super_admin? || user.editor?
  end

  def batch_add?
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
