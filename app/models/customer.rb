class Customer < ActiveRecord::Base
  self.table_name = 'jde_customers'
  
  has_many :brand_values
end