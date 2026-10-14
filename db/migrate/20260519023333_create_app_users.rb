class CreateAppUsers < ActiveRecord::Migration[7.1]
  def change
    return if table_exists?(:app_users)

    create_table :app_users do |t|
      t.string :nickname
      t.string :avatar
      t.string :phone, index: { unique: true }
      t.string :password_digest
      t.string :uuid, null: false, index: { unique: true }
      t.integer :role, null: false, default: 0
      t.boolean :is_vip, null: false, default: false
      t.datetime :vip_expires_at
      t.integer :reading_words, null: false, default: 0
      t.integer :reading_minutes, null: false, default: 0
      t.integer :books_read, null: false, default: 0
      t.string :device_id, limit: 64, index: { unique: true }
      t.bigint :grade_id, index: true
      t.string :wechat_openid, index: { unique: true }
      t.string :qq_openid, index: { unique: true }

      t.timestamps
    end
  end
end
