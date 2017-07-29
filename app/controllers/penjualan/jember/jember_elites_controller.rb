class Penjualan::Jember::JemberElitesController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, :authorize_user, :checking_params
  before_action :retail_weekly, only: :weekly
  before_action :retail_monthly, only: :monthly
  before_action :retail_daily, only: :daily
  
  def marketshare
    @area_potent = Marketshare.get_area_potential(initialize_brand, initialize_brach_id)
    gon.marketshare = Marketshare.get_report(initialize_brand, initialize_brach_id)
    gon.brand = initialize_brand
    @branch = "JEMBER"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/marketshare"
  end
  
  def daily
    gon.brand = initialize_brand
    gon.max = 100
    @branch = "JEMBER"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/daily"
  end
  
  def weekly
    gon.brand = initialize_brand
    gon.max = 100
    @customer_summary = Penjualan::Sale.customer_summary(initialize_brach_id, initialize_brand)
    @most_item = Penjualan::Sale.most_items_ordered_weekly(initialize_brach_id, initialize_brand)
    @branch = "JEMBER"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/weekly"
  end
  
  def monthly
    gon.brand = initialize_brand
    gon.max = 100
    @branch = "JEMBER"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/monthly"
  end
  
  private
  
  def initialize_brand
    "ELITE"
  end
  
  def initialize_brach_id
    22
  end

  def checking_params
    if params[:date].nil?
      date = '1/'+Date.yesterday.month.to_s+'/'+Date.yesterday.year.to_s
      @date = (date.to_date + Date.today.strftime('%d').to_i) - 1
    else
      date = '1/'+params[:date][:month].to_s+'/'+params[:date][:year].to_s
      @date = (date.to_date + Date.today.strftime('%d').to_i) - 1
    end
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, initialize_brand) || 
    bm(current_user, initialize_brach_id, initialize_brand) || sales(current_user, initialize_brach_id, initialize_brand)
  end
end