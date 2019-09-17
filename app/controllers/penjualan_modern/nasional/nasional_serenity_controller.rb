class PenjualanModern::Nasional::NasionalSerenityController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :authorize_user, :checking_params
  before_action :modern_nasional_weekly, only: :weekly
  before_action :modern_nasional_monthly, only: :monthly
  before_action :modern_nasional_this_month, only: :daily

  def daily
    gon.brand = initialize_brand
    gon.max = 2000
    @branch = "NASIONAL"
    @brand_name = initialize_brand
    render template: "penjualan/modern/modern_nasional_daily"
  end
  
  
  def weekly
    gon.brand = initialize_brand
    gon.max = 500
    @branch = "NASIONAL"
    @brand_name = initialize_brand
    render template: "penjualan/modern/modern_nasional_weekly"
  end

  def monthly
    gon.brand = initialize_brand
    gon.max = 2000
    @branch = "NASIONAL"
    @brand_name = initialize_brand
    render template: "penjualan/modern/modern_nasional_monthly"
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
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, initialize_brand)
  end
end