class SalesProductivityCustomer < ActiveRecord::Base
  belongs_to :sales_productivity, inverse_of: :sales_productivity_customers
  validate :empty_customer
  
  def empty_customer
    if self.customer.blank?
      errors[:base] << "This person is invalid because ..."
    end
  end
  
  before_save do
    self.customer = customer.strip.upcase if customer.present?
  end
  
  before_update do
    self.customer = customer.strip.upcase if customer.present?
  end
end