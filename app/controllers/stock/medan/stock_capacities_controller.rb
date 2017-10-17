class Stock::Medan::StockCapacitiesController < ApplicationController
  before_action :set_branch_plant
  
  def capacity
    @cap_stock = Stock::ItemAvailability.recap_cap_stock_report(@mat, @foam, @caps)
    render template: "stock/template_stock/stock_capacity"
  end

  private
  
  def set_branch_plant
    @caps = 5
    @mat = "11081"
    @foam = "11082"
    @branch = "MEDAN"
  end
end