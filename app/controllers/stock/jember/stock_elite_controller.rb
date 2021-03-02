class Stock::Jember::StockEliteController < ApplicationController
  before_action :set_branch_plant, :initialize_brand
  
  def stock_buffer
    @buf_stock = Stock::JdeItemAvailability.buffer_stock(@branch_plant, "E")
    @state = "NORMAL"
    render template: "stock/template_stock/stock_buffer"
  end
  
  def stock_classic
    @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant, "C")
    @brand = "CLASSIC"
    @state = "NORMAL"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_tote
    @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant, "O")
    @brand = "TOTE"
    @state = "NORMAL"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_normal
    @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant, "E")
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
    @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant + "C", "E")
    @brand = initialize_brand
    @state = "CLEARANCE"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_service
    @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant + "S", "E")
    @brand = initialize_brand
    @state = "DISPLAY"
    render template: "stock/template_stock/stock_normal"
  end
  
  private
  
  def initialize_brand
    "ELITE"
  end
  
  def initialize_brach_id
    22
  end
  
  def set_branch_plant
    @branch_plant = "18131"
    @branch = "JEMBER"
  end
end