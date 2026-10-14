class CreateSplashAds < ActiveRecord::Migration[7.1]
  def change
    create_table :splash_ads do |t|
      t.string :image_url, null: false, comment: '图片URL'
      t.string :link_type, null: false, comment: '链接类型: single_book/category'

      t.references :book, foreign_key: true, comment: '关联图书ID'
      t.references :category, foreign_key: true, comment: '关联分类ID'

      t.string :push_scope, null: false, default: 'all_users', comment: '推送范围: all_users/age_range/specific_users'
      t.integer :min_age, comment: '最小年龄'                                    
      t.integer :max_age, comment: '最大年龄'                                    
      t.json :user_group, comment: '指定用户群体'

      t.string :push_mode, null: false, default: 'immediate', comment: '推送方式: immediate/first_open_daily'
      t.datetime :scheduled_at, comment: '定时推送时间'

      t.string :status, null: false, default: 'draft', comment: '状态: draft/scheduled/active/expired/disabled'

      # 时间范围
      t.datetime :start_time, null: false, comment: '开始时间'
      t.datetime :end_time, null: false, comment: '结束时间'

      # 统计数据                                                                 
      t.integer :send_count, default: 0, comment: '发送数'                       
      t.integer :click_count, default: 0, comment: '点击数'                      
      t.decimal :delivery_rate, precision: 5, scale: 4, default: 0, comment: '送达率'

      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
