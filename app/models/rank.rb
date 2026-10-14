class Rank < ApplicationRecord
  audited
  belongs_to :grade
  belongs_to :category
  has_many :rank_contents, dependent: :destroy
  has_many :contents, dependent: :destroy

  def content_names
    res = []
    rank_contents.each do |x|
      res << x.content_name
    end
    res.join(" | ")
  end

  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "grade_id", "id", "id_value", "name", "sn", "updated_at"]
  end
end
