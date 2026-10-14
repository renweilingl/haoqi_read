class CreatePushNotificationGrades < ActiveRecord::Migration[7.1]
  def change
    create_table :push_notification_grades do |t|
      t.references :push_notification, null: false, foreign_key: true                    
      t.references :grade, null: false   
      t.timestamps
    end
    add_index :push_notification_grades, [:push_notification_id, :grade_id], unique: true, if_not_exists: true
  end
end
