# frozen_string_literal: true

class AddIsFreeToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :is_free, :boolean, default: false unless column_exists?(:books, :is_free)
  end
end
