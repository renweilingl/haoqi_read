# frozen_string_literal: true

Pundit::NotAuthorizedError.class_eval do
  def message
    "权限不足"
  end
end
