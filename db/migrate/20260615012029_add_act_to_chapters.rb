class AddActToChapters < ActiveRecord::Migration[7.1]
  def change
    add_column :chapters, :ld_file_path, :string
    add_column :chapters, :hd_file_path, :string
    add_column :chapters, :sd_file_, :string
    add_column :chapters, :snap_file_shot, :string

    add_column :chapters, :act_state, :boolean, :default => false
  end
end
