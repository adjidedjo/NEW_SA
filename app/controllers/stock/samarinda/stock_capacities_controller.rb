class Stock::Samarinda::StockCapacitiesController < ApplicationController
  before_action :set_branch_plant, :initialize_brand
  
  def capacity
    @cap_stock = Stock::ItemAvailability.recap_cap_stock_report(@mat, @foam, @caps)
    @brand = initialize_brand
    render template: "stock/template_stock/stock_capacity"
  end

  private
  
  def initialize_brand
    ""
  end
  
  def set_branch_plant
    @caps = 54
    @mat = "54"
    @branch = "SAMARINDA"
  end
end