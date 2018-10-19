class CreditLimits::Semarang::CreditChecksController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, :authorize_user
  
  def credit_checks
    @credit_checks = CustomerLimit.find_by_sql("
      SELECT * FROM customer_limits WHERE area_id = '#{initialize_brach_id}' AND amount_due IS NOT NULL
    ")
    @branch_name = Area.find(initialize_brach_id).area
    render template: "credit_limits/templates/credit_check"
  end

  private

  def initialize_brand
    "ELITE"
  end

  def initialize_brach_id
    8
  end

  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm_customers(current_user) ||
    bm_customers(current_user, initialize_brach_id) || sales_credit_limit(current_user, current_user.branch1, current_user.branch2)
  end
end