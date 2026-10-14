# 创建合辑表
# 参考图片需求文档：https://code.coze.cn/api/sandbox/coze_coding/file/proxy?...
#
# 合辑管理模块 - 用于管理绘本合辑，包含4个表单模块：
# 1. 基本信息：合辑名称、4种规格封面
# 2. 年龄与分类：年龄段、年龄范围、分类、主题
# 3. 内容属性：二级类型、编辑推荐语、出版社、总集数、作者、标签
# 4. 图片与介绍：图片简介、合辑简介

class CreateCompilations < ActiveRecord::Migration[7.1] 
  def change
    create_table :compilations, if_not_exists: true do |t|
      t.string :name, null: false, comment: '合辑名称'
      t.string :banner_image_url, comment: '合辑banner图片URL (1500×932, ≤500KB)'
      t.string :banner_image_name, comment: '合辑banner图片文件名'
      t.string :landscape_cover_url, comment: '横图封面URL (1125×540, ≤500KB)'
      t.string :landscape_cover_name, comment: '横图封面文件名'
      #t.string :portrait_cover_url, comment: '长方形封面URL (600×768, ≤300KB)'
      #t.string :portrait_cover_name, comment: '长方形封面文件名'
      #t.string :square_cover_url, comment: '正方形封面URL (600×600, ≤300KB)'
      #t.string :square_cover_name, comment: '正方形封面文件名'

      #t.json :age_groups, comment: '年龄段勾选（多选）'
      #t.integer :min_age, default: 0, comment: '最小年龄'
      #t.integer :max_age, default: 99, comment: '最大年龄'
      #t.string :recommended_age, comment: '最佳年龄推荐'

      #t.bigint :first_category_id, comment: '一级分类'
      #t.bigint :second_category_id, comment: '二级分类'
      #t.json :themes, comment: '主题分类'

      t.string :editor_recommendation, comment: '编辑推荐语（15字以内）'
      t.string :publisher, comment: '出版社'
      t.integer :total_count, default: 0, comment: '合辑总集数'
      t.string :author, comment: '作者'
      t.string :tags, comment: '内容标签'

      t.string :intro_image_url, comment: '图片简介URL'
      t.string :intro_image_name, comment: '图片简介文件名'
      t.text :content_description, comment: '合辑简介（富文本/Markdown）'
      t.text :description, comment: '内容简介'

      t.timestamps
    end

    add_index :compilations, :name, unique: true, if_not_exists: true

    # 创建合辑与年级的关联表
    create_table :compilation_grades, id: false, if_not_exists: true do |t|
      t.references :compilation, null: false, foreign_key: true
      t.references :grade, null: false
      t.timestamps
    end

    # 添加复合索引
    add_index :compilation_grades, [:compilation_id, :grade_id], unique: true, if_not_exists: true
  end
end
