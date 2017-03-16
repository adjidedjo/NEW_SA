class Penjualan::Tangerang::TangerangElitesController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, :authorize_user
  before_action :retail_weekly, only: :weekly
  before_action :retail_monthly, only: :monthly
  before_action :retail_daily, only: :daily
  
  def daily
    gon.brand = initialize_brand
    gon.max = 100
    @branch = "TANGERANG"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/daily"
  end
  
  def weekly
    gon.brand = initialize_brand
    gon.max = 500
    @customer_summary = Penjualan::Sale.customer_summary(23, initialize_brand)
    @most_item = Penjualan::Sale.most_items_ordered_weekly(23, initialize_brand)
    @branch = "TANGERANG"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/weekly"
  end
  
  def monthly
    gon.brand = initialize_brand
    gon.max = 2000
    @customer_summary = Penjualan::Sale.customer_summary_monthly(23, initialize_brand)
    @most_item =  Penjualan::Sale.most_items_ordered_monthly(23, initialize_brand)
    @branch = "TANGERANG"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/monthly"
  end
  
  private
  
  def initialize_brand
    "ELITE"
  end
  
  def initialize_brach_id
    23
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, initialize_brand) || 
    bm(current_user, initialize_brach_id, initialize_brand) || sales(current_user, initialize_brach_id, initialize_brand)
  end
end