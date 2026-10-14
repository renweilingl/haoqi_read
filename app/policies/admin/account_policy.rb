# frozen_string_literal: true

module Admin
  class AccountPolicy < ApplicationPolicy
    def index?
      super_admin?
    end

    def show?
      super_admin?
    end

    def create?
      super_admin?
    end

    def update?
      super_admin?
    end

    def destroy?
      super_admin? && user != record
    end

    def reset_password?
      super_admin?
    end

    class Scope < Scope
      def resolve
        if user.super_admin?
          scope.all
        else
          scope.none
        end
      end
    end
  end
end
