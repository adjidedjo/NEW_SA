class BasePrices::SecondRegionalBasePricesController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, 
  :initialize_brach_name
  
  def elite
    #elite
    @branch = initialize_brach_name
    @brand_name = 'Elite_REG-2'
    @region = 'REGIONAL 2'
    @bp = BasePrice.finding_bp_mattress(initialize_brach_id)
    render template: "base_prices/template/catalog_elite_base_prices"
  end
  
  def lady
    #lady
    @branch = initialize_brach_name
    @brand_name = 'Lady'
    @bp = BasePrice.finding_bp_divan(initialize_brach_id)
    render template: "base_prices/template/catalog_lady_base_prices"
  end
  
  def serenity
    #serenity
    @branch = initialize_brach_name
    @brand_name = 'Serenity'
    @bp = BasePrice.finding_bp_sorong(initialize_brach_id)
    render template: "base_prices/template/catalog_serenity_base_prices"
  end
  
  def royal
    #royal
    @branch = initialize_brach_name
    @brand_name = 'Royal'
    @bp = BasePrice.finding_bp_foam(initialize_brach_id)
    render template: "base_prices/template/catalog_royal_base_prices"
  end
  
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
    '11'
  end
  
  def initialize_brach_name
    "REGIONAL 2"
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, initialize_brand) || 
    bm(current_user, initialize_brach_id, initialize_brand) || sales(current_user, initialize_brach_id, initialize_brand)
  end
end