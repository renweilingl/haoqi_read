class CategoryPolicy < ApplicationPolicy
  attr_reader :user, :category

  def initialize(user, category)
    @user = user
    @category = category
  end

  # 所有用户都可以查看分类列表
  def index?
    true
  end

  # 所有用户都可以查看单个分类
  def show?
    true
  end

  # 超级管理员和编辑可以创建分类
  def create?
    user.super_admin? || user.editor?
  end

  # 超级管理员和编辑可以更新分类
  def update?
    user.super_admin? || user.editor?
  end

  # 超级管理员和编辑可以删除分类
  def destroy?
    return false unless user.super_admin? || user.editor?
    true
  end

  # 超级管理员和编辑可以管理推荐分类
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
