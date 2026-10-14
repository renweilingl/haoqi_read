# frozen_string_literal: true

module Admin
  class PermissionPolicy < ApplicationPolicy
    def index?
      super_admin?
    end

    def show?
      super_admin?
    end

    class Scope < Scope
      def resolve
        scope.all if user.super_admin?
      end
    end
  end
end
