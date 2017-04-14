class SalesProductivity < ActiveRecord::Base
  validates :salesmen_id, :brand_id, presence: true
end