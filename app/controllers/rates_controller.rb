class RatesController < ApplicationController
  include RolesHelper
  before_action :authorize_user
  
  def index
    @sales = SalesProductivity.retail_success_rate_all_branch
    @sales_prod = SalesProductivity.retail_productivity_all_branch
  end
  
  private
  
  def authorize_user
    render template: "pages/notfound" unless report_all_brand(current_user)
  end
end