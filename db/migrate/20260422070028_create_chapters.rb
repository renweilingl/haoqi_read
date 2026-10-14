class CreateChapters < ActiveRecord::Migration[7.1]
  def change
    create_table :chapters, if_not_exists: true do |t|
      # 基本信息                                                                 
      t.references :book, null: false, foreign_key: true, comment: '所属绘本'    
      t.string :name, null: false, comment: '章节名称'                           
      t.string :cover_image_url, comment: '章节封面图片URL'                      
      #t.string :cover_image_name, comment: '章节封面图片名'                      
                                                                                 
      # 内容                                                                     
      t.string :content_file_url, comment: '章节内容文件URL'                     
      t.string :content_file_name, comment: '章节内容文件名'                     
      t.string :content_file_type, comment: '内容文件类型 (epub/pdf/txt)'        
      #t.integer :content_file_size, comment: '内容文件大小(字节)'                
                                                                                 
      # 状态                                                                     
      t.boolean :is_free, default: false, comment: '是否免费'                    
      t.boolean :is_published, default: false, comment: '是否上线'               
      t.integer :sn, default: 0, comment: '排序'                         

      t.timestamps
    end
  end
end
