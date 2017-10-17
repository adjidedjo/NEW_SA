class Stock::Semarang::StockCapacitiesController < ApplicationController
  before_action :set_branch_plant
  
  def capacity
    @cap_stock = Stock::ItemAvailability.recap_cap_stock_report(@mat, @foam, @caps)
    render template: "stock/template_stock/stock_capacity"
  end

  private
  
  def set_branch_plant
    @caps = 8
    @mat = "11051"
    @foam = "11052"
    @branch = "SEMARANG"
  end
end