# frozen_string_literal: true

#Rails.application.config.sorcery.submodules = [:remember_me, :brute_force_protection, :session_timeout, :activity_logging]

# 使用 Sorcery 的 User 模型进行认证
Rails.application.config.sorcery.user_class = "User"

Rails.application.config.sorcery.configure do |config|
  #config.session_timeout = 3600 # 1 hour
  #config.session_timeout_from_last_action = false
  #config.concurrent_sessions = false
  #config.magic_login = false
  
  config.user_config do |user|
    user.username_attribute_names = [:email]
    user.password_attribute_name = :password
    user.email_attribute_name = :email
#    user.crypted_password_attribute_name = :password_digest
    #user.salt_attribute_name = :salt
    #user.stretches = 10
    #user.salt_join_token = "--"
  #  user.remember_me_token_attribute_name = :remember_me_token
  #  user.remember_me_token_expires_at_attribute_name = :remember_me_token_expires_at
  end

  #config.controller.configure do |controller|
  #  controller.session_store = :cookie_store
  #end
end
