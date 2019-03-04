class Stock::Bali::StockEliteController < ApplicationController
  before_action :set_branch_plant, :initialize_brand
  
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
  
  def stock_unnormal
    @stock = Stock::JdeItemAvailability.stock_real_unnormal(@branch_plant, "E")
    @brand = initialize_brand
    @branch = "BALI"
    @state = "NORMAL"
    render template: "stock/template_stock/stock_unnormal"
  end
  
  def stock_normal
    @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant, "E")
    @brand = initialize_brand
    @branch = "BALI"
    @state = "NORMAL"
    render template: "stock/template_stock/stock_normal"
  end
  
  def stock_display
    @stock = Stock::ItemAvailability.stock_display_report(@branch_plant + "D", "E")
    # @recap_display_stock = Stock::ItemAvailability.recap_display_stock_report(@branch_plant, "E")
    @brand = initialize_brand
    @state = "DISPLAY"
    render template: "stock/template_stock/stock_display_report"
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

  def stock_recap
    @recap_stock = Stock::ItemAvailability.recap_stock_report(@branch_plant, "E")
    @brand = initialize_brand
    render template: "stock/template_stock/recap_stock"
  end
  
  private
  
  def initialize_brand
    "ELITE"
  end
  
  def initialize_brach_id
    4
  end
  
  def set_branch_plant
    @branch_plant = "12071"
    @branch = "BALI"
  end
end