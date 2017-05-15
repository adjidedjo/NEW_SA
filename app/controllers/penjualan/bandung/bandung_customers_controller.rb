class Penjualan::Bandung::BandungCustomersController < ApplicationController
  include RolesHelper
  before_action :authorize_user, :checking_params, :initialize_branch_id
  def customer
    @branch = "Jawa Barat"
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
    2
  end

  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user)
  end
  
  def customer_params
    params.require(:month, :year).permit!  
  end
end