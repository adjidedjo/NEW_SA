class Penjualan::Lampung::LampungSerenityController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, :authorize_user
  before_action :retail_weekly, only: :weekly
  before_action :retail_monthly, only: :monthly
  before_action :retail_daily, only: :daily
  before_action :retail_sales_through, only: :sales_through
  before_action :retail_sales_stock_rate, only: :sales_stock_rate
  before_action :retail_success_rate, only: :success_rate
  
  def success_rate
    gon.brand = initialize_brand
    @branch = "LAMPUNG"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/success_rate"
  end
  
  def sales_stock_rate
    gon.brand = initialize_brand
    @branch = "LAMPUNG"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/sales_stock_rate"
  end
  
  def sales_through
    @branch = "LAMPUNG"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/sales_through"
  end
  
  def daily
    gon.brand = initialize_brand
    gon.max = 100
    @branch = "LAMPUNG"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/daily"
  end
  
  def weekly
    gon.brand = initialize_brand
    gon.max = 200
    @customer_summary = Penjualan::Sale.customer_summary(initialize_brach_id, initialize_brand)
    @most_item = Penjualan::Sale.most_items_ordered_weekly(initialize_brach_id, initialize_brand)
    @branch = "LAMPUNG"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/weekly"
  end
  
  def monthly
    gon.brand = initialize_brand
    gon.max = 500
    @branch = "LAMPUNG"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/monthly"
  end
  
  private
  
  def initialize_brand
    "SERENITY"
  end
  
  def initialize_brach_id
    13
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, initialize_brand) || 
    bm(current_user, initialize_brach_id, initialize_brand) || sales(current_user, initialize_brach_id, initialize_brand)
  end
end
