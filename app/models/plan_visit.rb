class PlanVisit < ApplicationRecord
  has_many :customer_plan_visits, inverse_of: :plan_visit, dependent: :destroy
  accepts_nested_attributes_for :customer_plan_visits, allow_destroy: true
  
  validates_associated :customer_plan_visits
  validate :customer_must_be_fill, on: :create
  
  def customer_must_be_fill
    errors.add(:base, "Silahkan Isi Customer") if self.customer_plan_visits.empty?
  end
  
  def reject_customers(attributes)
    attributes['customer'].blank?
  end
  
  before_save do
    self.branch_id = Salesman.find(self.sales_id).branch_id
  end
  
  def self.index_all(date, user)
    month = date.nil? ? Date.today.month : date[:month]
    year = date.nil? ? Date.today.year : date[:year]
    plan_visit_index = user.branch1.present? ? PlanVisit.where("MONTH(date_visit) = ? AND YEAR(date_visit) = ? 
    AND branch_id = ?", month, year, user.branch1) : PlanVisit.where("MONTH(date_visit) = ? AND YEAR(date_visit) = ?",
    month, year)
    return plan_visit_index
  end
end
