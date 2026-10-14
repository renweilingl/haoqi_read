class AddDurationToChapters < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:chapters, :duration)
      add_column :chapters, :duration, :integer, :default => 0
    end

    unless column_exists?(:chapters, :publish_date)
      add_column :chapters, :publish_date, :date
    end
  end
end
