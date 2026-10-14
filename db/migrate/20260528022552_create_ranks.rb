class CreateRanks < ActiveRecord::Migration[7.1]
  def change
    create_table :ranks do |t|
      t.belongs_to :grade
      t.string :name
      t.integer :sn, :default => 0

      t.timestamps
    end
  end
end
