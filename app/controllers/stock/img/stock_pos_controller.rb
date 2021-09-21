class Stock::Img::StockPosController < ApplicationController
  before_action :set_branch_plant, :initialize_brand
  
  def stock
    @stock = Stock::Img.stock_pos
    @brand = "ELITE"
    @state = "NORMAL"
    render template: "stock/template_stock/stock_img"
  end

  private
  
  def classic
    "CLASSIC"
  end
  
  def tote
    "TOTE"
  end
  
  def initialize_brand
    "ELITE"
  end
  
  def initialize_brach_id
    2
  end
  
  def set_branch_plant
    @branch_plant = "18011"
    @branch = "BANDUNG"
  end
end