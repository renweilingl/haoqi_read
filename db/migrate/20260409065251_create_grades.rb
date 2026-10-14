class CreateGrades < ActiveRecord::Migration[7.1]
  def change
    create_table :grades, if_not_exists: true do |t|
      t.string :group_name, :limit => 8 
      t.string :name, :limit => 16
      t.string :description, :limit => 32
      t.timestamps
    end
  end
end
