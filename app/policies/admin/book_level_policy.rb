class Admin::BookLevelPolicy < ApplicationPolicy
  def index?
    user.super_admin? || user.editor?
  end
  
  def show?
    user.super_admin? || user.editor?
  end
  
  def new?
    create?
  end
  
  def create?
    user.super_admin? || user.editor?
  end
  
  def edit?
    update?
  end
  
  def update?
    user.super_admin? || user.editor?
  end
  
  def destroy?
    user.super_admin?
  end
  
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
