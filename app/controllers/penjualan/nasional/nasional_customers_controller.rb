class Penjualan::Nasional::NasionalCustomersController < ApplicationController
  include RolesHelper
  before_action :authorize_user
  def national_customer
    @customers_old = Penjualan::Customer.nasional_customers_last_order
    @customer = Penjualan::Customer.nasional_customers_stat
    @total_cus = Penjualan::Customer.total_customers
    @total_new = Penjualan::Customer.total_new_customers
    @new_customer = Penjualan::Customer.nasional_new_customers_stat
    @new_growth = Penjualan::Customer.nasional_new_growth
    render template: "penjualan/template_dashboard/nasional_customer"
  end

  private

  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user)
  end
  
  def customer_params
    params.require(:month, :year).permit!  
  end
  
end