class User < ApplicationRecord
  audited
  authenticates_with_sorcery!

  # 角色枚举
  enum role: {
    super_admin: 'super_admin',
    editor: 'editor',
    operator: 'operator',
    finance: 'finance'
  }

  # 角色显示名称映射
  ROLE_NAMES = {
    super_admin: '超级管理员',
    editor: '编辑',
    operator: '运营',
    finance: '财务'
  }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, if: -> { new_record?}
  validates :password, confirmation: true, if: -> { new_record? }
  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: roles.keys }

  # 检查是否是超级管理员
  def super_admin?
    role == 'super_admin'
  end

  def operator?
    role == 'operator'
  end

  # 获取角色显示名称
  def role_name
    ROLE_NAMES[role.to_sym] || role
  end

  # Sorcery 需要的方法
  def remember_me!
    self.remember_me_token = SecureRandom.urlsafe_base64
    self.remember_me_token_expires_at = 2.weeks.from_now
    save(validate: false)
  end

  def forget_me!
    self.remember_me_token = nil
    self.remember_me_token_expires_at = nil
    save(validate: false)
  end
end
