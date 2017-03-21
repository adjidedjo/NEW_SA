class PenjualanSalesmanController < ApplicationController
  before_action :address_number
  before_action :retail_salesman_daily, only: :daily
  before_action :retail_salesman_weekly, only: :weekly
  before_action :retail_salesman_monthly, only: :monthly
  
  
  def daily
    render template: "penjualan_salesman/daily"
  end
  
  def weekly
    render template: "penjualan_salesman/weekly"
  end
  
  def monthly
    render template: "penjualan_salesman/monthly"
  end
  
  private
  
  def address_number
    @current_user = current_user
  end
end