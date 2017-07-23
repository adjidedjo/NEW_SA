class Customer < ActiveRecord::Base
  self.table_name = 'jde_customers'
  
  has_many :marketshares
  has_many :marketshare_brands
  
  before_save :customer_update
  
  def customer_update
    self.name.upcase!
    self.i_class = 'RET'
    self.state = 1
  end
end