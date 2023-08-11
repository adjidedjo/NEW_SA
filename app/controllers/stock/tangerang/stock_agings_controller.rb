class Stock::Tangerang::StockAgingsController < ApplicationController
  before_action :set_branch_plant, :check_admin
  
  def aging
    @age_stock = Stock::ItemAvailability.aging_stock_report(@mat, @mat)
    render template: "stock/template_stock/stock_aging"
  end

  private
  
  def set_branch_plant
    @caps = 10
    @mat = "18151"
    @branch = "tangerang"
  end

  def check_admin
    @user = current_user.position == 'admin'
    redirect_to root_path, alert: "You do not have permission" unless @user
  end
end
