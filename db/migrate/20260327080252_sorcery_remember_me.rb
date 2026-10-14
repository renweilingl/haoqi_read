class SorceryRememberMe < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :remember_me_token, :string, default: nil unless column_exists?(:users, :remember_me_token)
    add_column :users, :remember_me_token_expires_at, :datetime, default: nil unless column_exists?(:users, :remember_me_token_expires_at)

    add_index :users, :remember_me_token, if_not_exists: true

    add_column :users, :role, :string, default: 'editor', null: false unless column_exists?(:users, :role)
    add_index :users, :role, if_not_exists: true
  end
end
