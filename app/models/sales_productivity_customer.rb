class SalesProductivityCustomer < ActiveRecord::Base
  belongs_to :sales_productivity,  inverse_of: :sales_productivities
  
  before_create do
    self.customer = customer.strip.upcase! if customer.present?
  end
  
  before_update do
    self.customer = customer.strip.upcase! if customer.present?
  end
end