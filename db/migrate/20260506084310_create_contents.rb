class CreateContents < ActiveRecord::Migration[7.1]
  def change
    create_table :contents, if_not_exists: true do |t|
      t.references :content_group, null: false, foreign_key: true, comment: '关联内容分组'
      t.string :content_type, null: false, comment: '类型'

      t.string :img_url,  comment: '图片链接'
      t.bigint :compilation_id, comment: '合辑信息'
      t.bigint :book_id, comment: '单本信息'
      t.bigint :recommend_id, comment: '推荐信息'
      t.bigint :author_id, comment: '作者信息'

      t.integer :sn, default: 0, comment: '排序'

      t.timestamps
    end
  end
end
