class Stock::Pusat::StockRoyalController < ApplicationController
  before_action :set_branch_plant, :initialize_brand
  
  def stock_normal
    @stock = Stock::ItemAvailability.stock_report(@branch_plant, "R")
    @brand = initialize_brand
    @state = "NORMAL"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_display
    @stock = Stock::ItemAvailability.stock_display_report(@branch_plant + "D", "R")
    @brand = initialize_brand
    @state = "DISPLAY"
    render template: "stock/template_stock/stock_display_report"
  end
  
  def stock_clearence
    @stock = Stock::ItemAvailability.stock_report(@branch_plant + "C", "R")
    @brand = initialize_brand
    @state = "CLEARENCE"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_service
    @stock = Stock::ItemAvailability.stock_report(@branch_plant + "S", "R")
    @brand = initialize_brand
    @state = "DISPLAY"
    render template: "stock/template_stock/stock_normal"
  end
  
  private
  
  def initialize_brand
    "ROYAL"
  end
  
  def initialize_brach_id
    2
  end
  
  def set_branch_plant
    @branch_plant = "11002"
    @branch = "KANTOR PUSAT"
  end
end