class Stock::Jember::StockAgingsController < ApplicationController
  before_action :set_branch_plant
  
  def aging
    @age_stock = Stock::ItemAvailability.aging_stock_report(@mat, @mat)
    render template: "stock/template_stock/stock_aging"
  end

  private
  
  def set_branch_plant
    @caps = 10
    @mat = "18131"
    @branch = "jember"
  end
end
