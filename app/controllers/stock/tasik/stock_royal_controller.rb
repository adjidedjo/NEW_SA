class Stock::Tasik::StockRoyalController < ApplicationController
  before_action :set_branch_plant, :initialize_brand
  
  def stock_buffer
    @buf_stock = Stock::JdeItemAvailability.buffer_stock(@branch_plant, "E")
    @state = "NORMAL"
    render template: "stock/template_stock/stock_buffer"
  end
  
  def stock_unnormal
    @stock = Stock::JdeItemAvailability.stock_real_unnormal(@branch_plant, "R")
    @brand = initialize_brand
    @state = "UNNORMAL"
    render template: "stock/template_stock/stock_unnormal"
  end
  
  def stock_normal
    @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant, "R")
    @brand = initialize_brand
    @state = "NORMAL"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_display
    @stock = Stock::ItemAvailability.stock_display_report(@branch_plant + "D", "R")
    # @recap_display_stock = Stock::ItemAvailability.recap_display_stock_report(@branch_plant, "R")
    @brand = initialize_brand
    @state = "DISPLAY"
    render template: "stock/template_stock/stock_display_report"
  end
  
  def stock_clearence
    @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant + "C", "R")
    @brand = initialize_brand
    @state = "CLEARANCE"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_service
    @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant + "S", "R")
    @brand = initialize_brand
    @state = "DISPLAY"
    render template: "stock/template_stock/stock_normal"
  end

  def stock_recap
    @recap_stock = Stock::ItemAvailability.recap_stock_report(@branch_plant, "R")
    @brand = initialize_brand
    render template: "stock/template_stock/recap_stock"
  end
  
  private
  
  def initialize_brand
    "ROYAL"
  end
  
  def initialize_brach_id
    25
  end
  
  def set_branch_plant
    @branch_plant = "1801101"
    @branch = "TASIKMALAYA"
  end
end