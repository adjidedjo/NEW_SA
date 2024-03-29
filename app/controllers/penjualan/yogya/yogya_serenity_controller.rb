class Penjualan::Yogya::YogyaSerenityController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, :authorize_user, :checking_params
  before_action :retail_weekly, only: :weekly
  before_action :retail_monthly, only: :monthly
  before_action :retail_daily, only: :daily
  before_action :retail_sales_through, only: :sales_through
  before_action :retail_sales_stock_rate, only: :sales_stock_rate
  before_action :retail_success_rate, only: :success_rate

  def customer_monthly
    @branch = "YOGYAKARTA"
    @customer = Penjualan::Customer.reporting_customer_monthly(initialize_brach_id, initialize_brand)
    render template: "penjualan/template_dashboard/customer_monthly"
  end
  
  def marketshare
    @area_potent = Marketshare.get_area_potential(initialize_brand, initialize_brach_id)
    gon.marketshare = Marketshare.get_report(initialize_brand, initialize_brach_id)
    gon.brand = initialize_brand
    @branch = "YOGYAKARTA"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/marketshare"
  end
  
  def success_rate
    gon.brand = initialize_brand
    @branch = "YOGYAKARTA"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/success_rate"
  end
  
  def sales_stock_rate
    gon.brand = initialize_brand
    @branch = "YOGYAKARTA"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/sales_stock_rate"
  end
  
  def sales_through
    @branch = "YOGYAKARTA"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/sales_through"
  end
  
  def daily
    gon.brand = initialize_brand
    gon.max = 150
    @branch = "YOGYAKARTA"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/daily"
  end
  
  def weekly
    gon.brand = initialize_brand
    gon.max = 800
    @customer_summary = Penjualan::Sale.customer_summary(initialize_brach_id, initialize_brand)
    @most_item =  Penjualan::Sale.most_items_ordered_weekly(initialize_brach_id, initialize_brand)
    @branch = "YOGYAKARTA"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/weekly"
  end
  
  def monthly
    gon.brand = initialize_brand
    gon.max = 5000
    @branch = "YOGYAKARTA"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/monthly"
  end
  
  private

  def checking_params
    if params[:date].nil?
      date = '1/'+Date.yesterday.month.to_s+'/'+Date.yesterday.year.to_s
      @date = (date.to_date + Date.today.strftime('%d').to_i) - 1
    else
      date = '1/'+params[:date][:month].to_s+'/'+params[:date][:year].to_s
      @date = (date.to_date + Date.today.strftime('%d').to_i) - 1
    end
  end
  
  def initialize_brand
    "SERENITY|CLASSIC"
  end
  
  def initialize_brach_id
    10
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, initialize_brand) || 
    bm(current_user, initialize_brach_id, initialize_brand) || sales(current_user, initialize_brach_id, initialize_brand)
  end
end
