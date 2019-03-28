class PagesController < ApplicationController
  layout 'pages'

  def login
  end

  def register
  end

  def recover
  end

  def lock
  end

  # set another layout for a specific action
  def template
    @sales_month = Penjualan::SalesmanSales.revenue_sales(current_user) if current_user.present? && current_user.position == 'sales'
    render :layout => 'application'
  end

  def notfound
  end

  def error500
  end

  def maintenance
  end
  
  def sales
  end
end
