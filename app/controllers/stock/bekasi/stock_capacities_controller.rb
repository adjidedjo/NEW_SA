class Stock::Bekasi::StockCapacitiesController < ApplicationController
  before_action :set_branch_plant
  
  def capacity
    @cap_stock = Stock::ItemAvailability.recap_cap_stock_report(@mat, @foam, @caps)
    render template: "stock/template_stock/stock_capacity"
  end

  private
  
  def set_branch_plant
    @caps = 3
    @mat = "11031"
    @foam = "11032"
    @branch = "BEKASI"
  end
end