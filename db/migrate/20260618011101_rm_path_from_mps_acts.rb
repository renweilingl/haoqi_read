class RmPathFromMpsActs < ActiveRecord::Migration[7.1]
  def change
    remove_column :mps_acts, :ld_file_path
    remove_column :mps_acts, :hd_file_path
    remove_column :mps_acts, :sd_file_path
  end
end
