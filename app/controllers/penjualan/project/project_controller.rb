class Penjualan::ProjectController < ApplicationController
  include RolesHelper
  before_action :authorize_user, :checking_params, :initialize_branch_id
  
  def monthly
    @pro_monthly = Penjualan::Project.sale_monthly_project()
    render template: "penjualan/template_dashboard/customer"
  end
  
  def yearly
    @pro_yearly = Penjualan::Customer.reporting_customers(@month, @year, initialize_branch_id)
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
    8
  end

  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user)
  end
  
  def customer_params
    params.require(:month, :year).permit!  
  end
end