class PenjualanSalesmanController < ApplicationController
  before_action :address_number
  before_action :elite_brand, only: :elite
  before_action :lady_brand, only: :lady
  before_action :serenity_brand, only: :serenity
  before_action :royal_brand, only: :royal
  before_action :retail_salesman_daily, only: [:elite, :lady, :royal, :serenity]
  before_action :retail_salesman_weekly, only: :weekly
  before_action :retail_salesman_monthly, only: :monthly
  
  
  def elite
    sales_page(current_user, @brand) ? (render template: "penjualan_salesman/daily") : (render template: "pages/notfound") 
  end
  
  def lady
    sales_page(current_user, @brand) ? (render template: "penjualan_salesman/daily") : (render template: "pages/notfound")
  end
  
  def serenity
    sales_page(current_user, @brand) ? (render template: "penjualan_salesman/daily") : (render template: "pages/notfound")
  end
  
  def royal
    sales_page(current_user, @brand) ? (render template: "penjualan_salesman/daily") : (render template: "pages/notfound")
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
  
  def elite_brand
    @brand = 'ELITE'
  end
  
  def lady_brand
    @brand = 'LADY'
  end
  
  def serenity_brand
    @brand = 'SERENITY'
  end
  
  def royal_brand
    @brand = 'ROYAL'
  end
end