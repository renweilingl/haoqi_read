class HeadImg < ApplicationRecord

  def self.ransackable_attributes(auth_object = nil)
    ["is_vip"]
  end

end
