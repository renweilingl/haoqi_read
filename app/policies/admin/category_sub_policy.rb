# frozen_string_literal: true

module Admin
  class CategorySubPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        scope.all
      end
    end

    def index?
      user.super_admin? || user.editor?
    end

    def new?
      user.super_admin? || user.editor?
    end

    def create?
      user.super_admin? || user.editor?
    end

    def update?
      user.super_admin? || user.editor?
    end

    def destroy?
      user.super_admin? || user.editor?
    end
  end
end
