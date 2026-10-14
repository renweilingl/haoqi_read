# frozen_string_literal: true

class AddPackageIdToOrders < ActiveRecord::Migration[7.1]
  def change
    return if column_exists?(:orders, :package_id)

    add_column :orders, :package_id, :bigint
    add_index :orders, :package_id
  end
end