class Stock::Jember::StockLadyController < ApplicationController
  before_action :set_branch_plant, :initialize_brand
  
  def stock_buffer
    @buf_stock = Stock::JdeItemAvailability.buffer_stock(@branch_plant, "L")
    @state = "NORMAL"
    render template: "stock/template_stock/stock_buffer"
  end
  
  def stock_normal
    @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant, "L")
    @brand = initialize_brand
    @state = "NORMAL"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_display
    @stock = Stock::ItemAvailability.stock_display_report(@branch_plant + "D", "R")
    @brand = initialize_brand
    @state = "DISPLAY"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_clearence
    @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant + "C", "L")
    @brand = initialize_brand
    @state = "CLEARANCE"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_service
    @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant + "S", "L")
    @brand = initialize_brand
    @state = "DISPLAY"
    render template: "stock/template_stock/stock_normal"
  end
  
  private
  
  def initialize_brand
    "LADY"
  end
  
  def initialize_brach_id
    2
  end
  
  def set_branch_plant
    @branch_plant = "18131"
    @branch = "JEMBER"
  end
end