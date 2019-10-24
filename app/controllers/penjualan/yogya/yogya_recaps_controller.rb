class Penjualan::Yogya::YogyaRecapsController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, :authorize_bm, :checking_params
  before_action :retail_recap, :authorize_bm, only: :recap

  def recap
    gon.brand = initialize_brand
    @branch = "Yogyakarta"
    @brand_name = initialize_brand
    render template: "penjualan/template_dashboard/recap_branch"
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
    "ELITE"
  end

  def initialize_brach_id
    10
  end
  
  def authorize_bm
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, initialize_brand) || 
    bm_customers(current_user, initialize_brach_id)
  end
end