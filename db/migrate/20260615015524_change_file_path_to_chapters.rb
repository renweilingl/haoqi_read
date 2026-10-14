class ChangeFilePathToChapters < ActiveRecord::Migration[7.1]
  def change
    rename_column :chapters, :sd_file_, :sd_file_path
    rename_column :chapters, :snap_file_shot, :snap_file_path
  end
end
