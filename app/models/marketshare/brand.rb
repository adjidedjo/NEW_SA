class Marketshare::Brand < ActiveRecord::Base
  has_many :brand_values
  belongs_to :brand_type
  
  validates :brand_type_id, uniqueness: { scope: :name, message: " & Name is available" }
end