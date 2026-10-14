class Admin::PermissionsController < ApplicationController
  before_action :require_login
  before_action :set_descriptions

  def index
    authorize nil, policy_class: Admin::PermissionPolicy
    @roles = User.roles.keys
  end

  def show
    authorize nil, policy_class: Admin::PermissionPolicy
    @role = params[:id]
    unless User.roles.keys.include?(@role)
      redirect_to admin_permissions_path, alert: "角色不存在"
      return
    end
    
    @users_by_role = User.where(role: @role).order(created_at: :desc)
  end

  private

  def set_descriptions
    @role_descriptions = {
      super_admin: {
        name: '超级管理员',
        description: '拥有系统的最高权限，可以管理所有账号和权限',
        permissions: ['账号管理', '角色管理', '权限分配', '操作日志', '系统设置']
      },
      editor: {
        name: '编辑',
        description: '负责内容管理和编辑工作',
        permissions: ['文章管理', '图片管理', '分类管理']
      },
      operator: {
        name: '运营',
        description: '负责日常运营和数据统计',
        permissions: ['数据统计', '消息推送', '活动管理']
      },
      finance: {
        name: '财务',
        description: '负责财务相关事务',
        permissions: ['财务管理', '订单查询', '报表统计']
      }
    }
  end
end
