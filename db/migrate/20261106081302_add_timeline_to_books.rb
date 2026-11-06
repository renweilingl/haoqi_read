class AddTimelineToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :time_line, :text
  end
end
