class CustomerPlanVisit < ApplicationRecord
  belongs_to :plan_visit, inverse_of: :customer_plan_visits
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
