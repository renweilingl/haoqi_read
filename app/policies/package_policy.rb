class PackagePolicy < ApplicationPolicy
  def index?
    user.operator? || user.super_admin?
  end
  
  def new?
    create?
  end
  
  def create?
    user.operator? || user.super_admin?
  end
  
  def edit?
    update?
  end
  
  def update?
    user.operator? || user.super_admin?
  end
  
  def destroy?
    user.operator? || user.super_admin?
  end
  
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
