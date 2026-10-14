class CreateMpsActs < ActiveRecord::Migration[7.1]
  def change
    create_table :mps_acts do |t|
      t.string :oss_object
      t.string :content_file_url
      t.string :run_id

      t.string :ld_file_path
      t.string :hd_file_path
      t.string :sd_file_path

      t.timestamps
    end
    remove_column :chapters, :snap_file_path
  end
end
