# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    super_admin?
  end

  def show?
    super_admin? || user == record
  end

  def create?
    super_admin?
  end

  def update?
    super_admin? || user == record
  end

  def destroy?
    super_admin? && user != record
  end

  def reset_password?
    super_admin? || user == record
  end

  class Scope < Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end
