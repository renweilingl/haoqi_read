class Package < ApplicationRecord
  audited

  has_many :orders
end
