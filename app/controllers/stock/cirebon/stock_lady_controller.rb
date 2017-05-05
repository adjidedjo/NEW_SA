class Stock::Cirebon::StockLadyController < ApplicationController
  before_action :set_branch_plant, :initialize_brand
  
  def stock_normal
    @stock = Stock::ItemAvailability.stock_report(@branch_plant, "L")
    @brand = initialize_brand
    @state = "NORMAL"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_display
    @stock = Stock::ItemAvailability.stock_display_report(@branch_plant + "D", "L")
    @brand = initialize_brand
    @state = "DISPLAY"
    render template: "stock/template_stock/stock_display_report"
  end
  
  def stock_clearence
    @stock = Stock::ItemAvailability.stock_report(@branch_plant + "C", "L")
    @brand = initialize_brand
    @state = "CLEARENCE"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_service
    @stock = Stock::ItemAvailability.stock_report(@branch_plant + "S", "L")
    @brand = initialize_brand
    @state = "DISPLAY"
    render template: "stock/template_stock/stock_normal"
  end

  def stock_recap
    @recap_stock = Stock::ItemAvailability.recap_stock_report(@branch_plant, "L")
    @brand = initialize_brand
    render template: "stock/template_stock/recap_stock"
  end
  
  private
  
  def initialize_brand
    "LADY"
  end
  
  def initialize_brach_id
    9
  end
  
  def set_branch_plant
    @branch_plant = "13021"
    @branch = "CIREBON"
  end
end