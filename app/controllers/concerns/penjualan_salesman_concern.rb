module PenjualanSalesmanConcern
  extend ActiveSupport::Concern
  
  # DAILY SALESMAN REPORT
  def revenue_sales
    @sales_month = Penjualan::SalesmanSales.revenue_sales(current_user)
  end
  
  def revenue_this_month_sales
    @sales_revenue_this_month = Penjualan::SalesmanSales.revenue_this_month_sales(current_user, @brand)
  end
  
  def daily_product_sales
    @sales_daily_product = Penjualan::SalesmanSales.sales_daily_product(@current_user, @brand)
  end
  
  def this_week_product_sales
    @this_week_product = Penjualan::SalesmanSales.this_week(@current_user, @brand)
  end
  
  def this_month_product_sales
    @this_month_product = Penjualan::SalesmanSales.this_month(@current_user, @brand)
  end
  
  def this_month_city_sales
    @this_month_city = Penjualan::SalesmanSales.this_month_city(@current_user, @brand)
  end
  
  def this_month_customer_sales
    @this_month_customer = Penjualan::SalesmanSales.this_month_customer(@current_user, @brand)
  end
  
  def this_month_article_sales
    @this_month_article = Penjualan::SalesmanSales.this_month_article(@current_user, @brand)
  end
  
  # WEEKLY SALESMAN REPORT
  
  def weekly_product_sales
    @last_week_product = Penjualan::SalesmanSales.last_week(@current_user)
  end
  
  def weekly_city_sales
    @last_week_city = Penjualan::SalesmanSales.last_week_city(@current_user)
  end
  
  def weekly_customer_sales
    @last_week_customer = Penjualan::SalesmanSales.last_week_customer(@current_user)
  end
  
  def weekly_article_sales
    @last_week_article = Penjualan::SalesmanSales.last_week_article(@current_user)
  end
  
  # MONTHLY SALESMAN REPORT
  
  def monthly_product_sales
    @last_month_product = Penjualan::SalesmanSales.last_month(@current_user)
  end
  
  def monthly_city_sales
    @last_month_city = Penjualan::SalesmanSales.last_month_city(@current_user)
  end
  
  def monthly_customer_sales
    @last_month_customer = Penjualan::SalesmanSales.last_month_customer(@current_user)
  end
  
  def monthly_article_sales
    @last_month_article = Penjualan::SalesmanSales.last_month_article(@current_user)
  end
  
end