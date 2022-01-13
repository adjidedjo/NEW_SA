class Stock::RoyalTiga::StockEliteController < ApplicationController
  before_action :set_branch_plant, :initialize_brand
  
  def stock_ba
    @stock = Stock::JdeItemAvailability.stock_real_jde_with_location("11001BA", "PRD", "R3")
    @brand = "11001BA WITH LOCATION PROD"
    @state = "NORMAL"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_sa
    @stock = Stock::JdeItemAvailability.stock_real_jde_without_loc("11001SA", "R3")
    @brand = "11001SA"
    @state = "NORMAL"
    render template: "stock/template_stock/stock_accessories"
  end
  
  private
  
  def initialize_brand
    "ELITE"
  end
  
  def initialize_brach_id
    2
  end
  
  def set_branch_plant
    @branch_plant = "11001BCP"
    @branch = "ROYAL TIGA"
  end
end