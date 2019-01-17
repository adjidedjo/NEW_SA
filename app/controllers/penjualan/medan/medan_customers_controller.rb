class Penjualan::Medan::MedanCustomersController < ApplicationController
  include RolesHelper
  before_action :authorize_user, :checking_params, :initialize_branch_id
  
  def customer_active
    @branch = "Medan"
    @customer = Penjualan::Customer.active_customers(initialize_branch_id)
    @list_customers = Penjualan::Customer.list_customers(params[:branch],
    params[:brand]) if params[:branch].present?
    render template: "penjualan/template_dashboard/customer_active"     
  end
  
  def customer
    @branch = "Medan"
    @customer = Penjualan::Customer.reporting_customers(@month, @year, initialize_branch_id)
    render template: "penjualan/template_dashboard/customer"
  end

  private

  def checking_params
    if params[:date].nil?
      @month = Date.yesterday.month
      @year = Date.yesterday.year
    else
      @month = params[:date][:month]
      @year = params[:date][:year]
    end
  end

  def initialize_branch_id
    5
  end

  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm_customers(current_user) || 
    bm_customers(current_user, initialize_branch_id)
  end
  
  def customer_params
    params.require(:month, :year).permit!  
  end
end