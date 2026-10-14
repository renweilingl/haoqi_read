class CompilationPolicy < ApplicationPolicy
  attr_reader :user, :compilation

  def initialize(user, compilation)
    @user = user
    @compilation = compilation
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

  def chapters?
    user.super_admin? || user.editor?
  end

  def books?
    user.super_admin? || user.editor?
  end

  def new_chapter?
    user.super_admin? || user.editor?
  end

  # 超级管理员和编辑可以删除分类
  def destroy?
    return false unless user.super_admin? || user.editor?
    true
  end

  def upload_cover?
    user.super_admin? || user.editor?
  end

  def upload_intro_image?
    user.super_admin? || user.editor?
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
