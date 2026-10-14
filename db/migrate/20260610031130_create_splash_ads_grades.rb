class CreateSplashAdsGrades < ActiveRecord::Migration[7.1]
  def change
    create_table :splash_ad_grades do |t|
      t.references :splash_ad, null: false, foreign_key: true
      t.references :grade, null: false

      t.timestamps
    end
    add_index :splash_ad_grades, [:splash_ad_id, :grade_id], unique: true, if_not_exists: true
  end
end
