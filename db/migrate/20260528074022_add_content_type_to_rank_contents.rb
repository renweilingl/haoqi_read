class AddContentTypeToRankContents < ActiveRecord::Migration[7.1]
  def change
    add_column :rank_contents, :content_type, :string, :default => "book"
  end
end
