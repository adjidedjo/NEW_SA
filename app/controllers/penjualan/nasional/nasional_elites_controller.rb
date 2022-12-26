class Penjualan::Nasional::NasionalElitesController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :authorize_user, :checking_params
  before_action :retail_nasional_weekly, only: :weekly
  before_action :retail_nasional_monthly, only: :monthly
  before_action :retail_nasional_this_month, only: :daily

  def customer_progress
    @brand_name = initialize_brand
    @customer = Penjualan::Customer.customer_progress(initialize_brand)
    render template: "penjualan/template_dashboard/customer_progress"
  end
  
  def customer_decrease
    @brand_name = initialize_brand
    @customer = Penjualan::Customer.customer_decrease(initialize_brand)
    render template: "penjualan/template_dashboard/customer_decrease"
  end
  
  def daily
    gon.brand = initialize_brand
    gon.max = 3000
    @branch = "NASIONAL"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/retail_nasional_daily"
  end

  def weekly
    gon.brand = initialize_brand
    gon.max = 500
    @branch = "NASIONAL"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/retail_nasional_weekly"
  end

  def monthly
    gon.brand = initialize_brand
    gon.max = 2000
    @branch = "NASIONAL"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/retail_nasional_monthly"
  end

  private

  def checking_params
    if params[:date].nil?
      date = '1/'+Date.yesterday.month.to_s+'/'+Date.yesterday.year.to_s
      @date = (date.to_date + Date.today.strftime('%d').to_i) - 1
    else
      date = '1/'+params[:date][:month].to_s+'/'+params[:date][:year].to_s
      @date = date.to_date
    end
  end

  def initialize_brand
    "ELITE"
  end

  def authorize_user
    render template: "pages/notfound" unless administrator(current_user) || general_manager(current_user) || nsm(current_user, initialize_brand)
  end
end