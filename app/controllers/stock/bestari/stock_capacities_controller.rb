class Stock::Bestari::StockCapacitiesController < ApplicationController
  before_action :set_branch_plant, :check_admin
  
  def capacity
    @cap_stock = Stock::ItemAvailability.recap_cap_stock_report(@mat, @foam, @caps)
    render template: "stock/template_stock/stock_capacity"
  end

  private
  
  def set_branch_plant
    @caps = 50
    @mat = "50"
    @branch = "BESTARI"
  end

  def check_admin
    @user = current_user.position == 'admin'
    redirect_to root_path, alert: "You do not have permission" unless @user
  end
end