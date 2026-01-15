class Stock::BaliController < ApplicationController
  before_action :set_branch_plant

  def show
    @brand_param = params[:brand].upcase
    @category_param = params[:category].downcase
    @brand = map_brand(@brand_param)
    
    # Defaults
    @branch = "BALI"
    
    case @category_param
    when 'buffer'
      @buf_stock = Stock::JdeItemAvailability.buffer_stock(@branch_plant, brand_code(@brand_param))
      @state = "BUFFER"
      @inner_template = "stock/template_stock/stock_buffer"
    when 'classic'
      @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant, "C")
      @brand = "CLASSIC"
      @state = "NORMAL"
      @inner_template = "stock/template_stock/stock_normal"
    when 'tote'
      @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant, "O")
      @brand = "TOTE"
      @state = "NORMAL"
      @inner_template = "stock/template_stock/stock_normal"
    when 'unnormal'
      @stock = Stock::JdeItemAvailability.stock_real_unnormal(@branch_plant, brand_code(@brand_param))
      @state = "UNNORMAL"
      @inner_template = "stock/template_stock/stock_unnormal"
    when 'normal'
      @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant, brand_code(@brand_param))
      @state = "NORMAL"
      @inner_template = "stock/template_stock/stock_normal"
    when 'display'
      @stock = Stock::ItemAvailability.stock_display_report(@branch_plant + "D", brand_code(@brand_param))
      @state = "DISPLAY"
      @inner_template = "stock/template_stock/stock_display_report"
    when 'clearance'
      @stock = Stock::JdeItemAvailability.stock_real_jde_web(@branch_plant + "C", brand_code(@brand_param))
      @state = "CLEARANCE"
      @inner_template = "stock/template_stock/stock_normal"
    when 'service'
      @stock = Stock::ItemAvailability.stock_report(@branch_plant + "S", brand_code(@brand_param))
      @state = "SERVICE"
      @inner_template = "stock/template_stock/stock_normal"
    when 'recap'
      @recap_stock = Stock::ItemAvailability.recap_stock_report(@branch_plant, brand_code(@brand_param))
      @inner_template = "stock/template_stock/recap_stock"
    else
      render plain: "Category not found", status: 404
      return
    end

    render "stock/bali/show"
  end

  private

  def set_branch_plant
    @branch_plant = "12071"
  end

  def map_brand(name)
    case name
    when 'ELITE' then 'ELITE'
    when 'LADY' then 'LADY' # Assuming Lady Americana
    when 'SERENITY' then 'SERENITY'
    when 'ROYAL' then 'ROYAL'
    when 'CLASSIC' then 'CLASSIC'
    when 'TOTE' then 'TOTE'
    else name
    end
  end

  def brand_code(name)
    case name
    when 'ELITE' then 'E'
    when 'LADY' then 'L'
    when 'SERENITY' then 'S'
    when 'ROYAL' then 'R'
    # Classic and Tote might use specific codes in queries directly
    # but for consistent mapping:
    when 'CLASSIC' then 'C' 
    when 'TOTE' then 'O'
    else 'E' # Default or Error
    end
  end
end
