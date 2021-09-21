class PenjualanDirect::NasionalEcom::NasionalRoyalController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :authorize_user, :checking_params
  before_action :direct_nasional_weekly, only: :weekly
  before_action :direct_nasional_monthly, only: :monthly
  before_action :direct_ecom_nasional_this_month, only: :daily

  def daily
    gon.brand = initialize_brand
    gon.max = 2000
    @branch = "ECOMMERCE"
    @brand_name = initialize_brand
    render template: "penjualan/direct/direct_nasional_daily"
  end
  
  
  def weekly
    gon.brand = initialize_brand
    gon.max = 500
    @branch = "NASIONAL"
    @brand_name = initialize_brand
    render template: "penjualan/direct/direct_nasional_weekly"
  end

  def monthly
    gon.brand = initialize_brand
    gon.max = 2000
    @branch = "NASIONAL"
    @brand_name = initialize_brand
    render template: "penjualan/direct/direct_nasional_monthly"
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
    "ROYAL"
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm_direct(current_user) || admin_direct_img(current_user)
  end
end
