class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books, if_not_exists: true do |t|
      # 核心基础信息
      t.string :name, null: false, comment: '绘本名称'
      t.string :cover_image_url, comment: '绘本封面URL'
      t.belongs_to :category, comment: '绘本类型'
      #t.integer :min_age, default: 0, comment: '最小年龄'
      #t.integer :max_age, default: 99, comment: '最大年龄'
      #t.string :recommended_age, comment: '最佳年龄推荐'
      #t.boolean :cat_display, default: false, comment: '分类展示'
      t.json :themes, comment: '主题'
      t.references :supplier, foreign_key: true, comment: '归属供应商'

      # 版权与出版信息
      #t.boolean :has_copyright, default: false, comment: '是否有版权'
      #t.string :payment_type, default: 'free', comment: '付费类型: free/paid/vip'
      #t.decimal :price, precision: 10, scale: 2, default: 0.0, comment: '单价'
      #t.string :publisher, comment: '出版社'
      #t.boolean :has_isbn, default: false, comment: '是否存在ISBN'

      # 作者/译者信息
      #t.string :author, comment: '作者'
      #t.string :translator, comment: '译者'
      #t.string :compiler, comment: '编著'
      #t.string :illustrator, comment: '编绘'
      #t.string :editor_in_chief, comment: '主编'
      #t.json :awards, comment: '关联奖项'

      # 内容与展示信息
      #t.text :description, comment: '内容简介'
      #t.string :orientation, default: 'portrait', comment: '横屏/竖屏: portrait/landscape'
      #t.string :intro_image_url, comment: '图片简介URL'
      #t.text :image_description, comment: '图片文字(app不展示)'
      #t.boolean :purchasable, default: true, comment: '是否可购买'
      #t.string :editor_recommendation, comment: '编辑推荐语'
      #t.string :detail_recommendation, comment: '详情页推荐语'
      #t.integer :page_count, default: 0, comment: '页数'
      #t.boolean :full_trial_read, default: false, comment: '是否整本试读'
      #t.integer :trial_page_count, default: 0, comment: '试读页数'
      #t.integer :word_count, default: 0, comment: '字数'
      #t.text :remark, comment: '备注'

      # 状态与数据设置
      #t.datetime :scheduled_online_at, comment: '定时上线时间'
      #t.boolean :locked, default: false, comment: '是否锁定'
      #t.string :status, default: 'draft', comment: '状态: draft/published/offline'
      #t.integer :base_read_count, default: 0, comment: '基础阅读人数'
      #t.integer :base_rating_count, default: 0, comment: '基础评分人数'
      #t.decimal :base_rating, precision: 3, scale: 1, default: 0.0, comment: '基础评分'

      t.timestamps
    end

    add_index :books, :name, if_not_exists: true

    # 创建合辑与年级的关联表
    create_table :book_grades, id: false, if_not_exists: true do |t|
      t.references :book, null: false, foreign_key: true
      t.references :grade, null: false
      t.timestamps
    end

    add_index :book_grades, [:book_id, :grade_id], unique: true, if_not_exists: true
  end
end
