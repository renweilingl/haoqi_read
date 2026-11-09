class CreateBookContents < ActiveRecord::Migration[7.1]
  def change
    create_table :book_contents do |t|
      t.belongs_to :book
      t.string :img_path
      t.string :name
      t.string :start_at
      t.string :deal_at
      t.integer :sn
      t.integer :height
      t.integer :width

      t.timestamps
    end
  end
end
