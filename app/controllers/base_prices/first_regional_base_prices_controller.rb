class BasePrices::FirstRegionalBasePricesController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, 
  :initialize_brach_name
  
  def base_price_mattress
    @branch = initialize_brach_name
    @brand_name = initialize_brand
    @bp = BasePrice.finding_bp_mattress(initialize_brach_id)
    render template: "base_prices/template/base_prices"
  end
  
  def base_price_divan
    @branch = initialize_brach_name
    @brand_name = initialize_brand
    @bp = BasePrice.finding_bp_divan(initialize_brach_id)
    render template: "base_prices/template/base_prices"
  end
  
  def base_price_sorong
    @branch = initialize_brach_name
    @brand_name = initialize_brand
    @bp = BasePrice.finding_bp_sorong(initialize_brach_id)
    render template: "base_prices/template/base_prices"
  end
  
  def base_price_foam
    @branch = initialize_brach_name
    @brand_name = initialize_brand
    @bp = BasePrice.finding_bp_foam(initialize_brach_id)
    render template: "base_prices/template/base_prices"
  end
  
  private
  
  def initialize_brand
    "ELITE"
  end
  
  def initialize_brach_id
    '02'
  end
  
  def initialize_brach_name
    "REGIONAL 1"
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, initialize_brand) || 
    bm(current_user, initialize_brach_id, initialize_brand) || sales(current_user, initialize_brach_id, initialize_brand)
  end
end