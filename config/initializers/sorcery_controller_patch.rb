# 确保 Sorcery 模块在控制器之前被正确加载
# 这个配置修复 "Before process_action callback :require_login has not been defined" 错误

# 配置 Rails 的自动加载行为
Rails.application.config.after_initialize do
  # 确保 ApplicationController 包含 Sorcery::Controller
  unless ApplicationController.ancestors.include?(Sorcery::Controller)
    ApplicationController.send(:include, Sorcery::Controller)
  end
  
  # 确保 Sorcery 的 require_login 方法可以被正确调用
  ApplicationController.class_eval do
    define_method :require_login do
      redirect_to login_path, alert: "请先登录" unless logged_in?
    end
  end
end
