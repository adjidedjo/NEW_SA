class Area < ActiveRecord::Base
  has_many :brand_value, class_name: 'Marketshare::BrandValue'
end