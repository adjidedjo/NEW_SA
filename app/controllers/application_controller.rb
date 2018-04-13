class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  include PenjualanConcern
  include PenjualanDailyConcern
  include PenjualanSalesmanConcern
  include OrderDailyConcern
  include ArConcern
  include Rails::Pagination
  helper_method :retail_weekly, :retail_monthly, :retail_daily, :order_daily, 
  :retail_salesman_daily, :retail_sales_stock_rate, :retail_sales_through,
  :retail_nasional_weekly, :retail_nasional_monthly, :retail_success_rate,
  :retail_uncollectable_ar, :retail_collectable_ar, :retail_nasional_this_month,
  :retail_recap
  
  def retail_recap
    retail_recap_conc
  end
  
  def retail_nasional_this_month
    retail_nasional_this_month_branches_conc
    retail_nasional_this_month_branch_conc
    # retail_nasional_this_month_conc
  end
  
  def retail_collectable_ar
    retail_collectable_ar_conc
  end
  
  def retail_uncollectable_ar
    retail_uncollectable_ar10_conc
    retail_uncollectable_ar20_conc
  end
  
  def retail_success_rate
    retail_success_rate_conc
    retail_productivity_conc
  end
  
  def retail_nasional_monthly
    retail_nasional_monthly_branches_conc
    retail_nasional_monthly_branch_conc
    # retail_nasional_monthly_conc
  end
  
  def retail_nasional_weekly
    retail_nasional_weekly_conc
    retail_nasional_weekly_branch_conc
  end
  
  def retail_sales_stock_rate
    sales_stock_rate_product_conc
    sales_stock_rate_conc
  end
  
  def retail_sales_through
    sales_through
  end
  
  def retail_salesman_monthly
    monthly_product_sales
    monthly_article_sales
    monthly_customer_sales
    monthly_city_sales
  end
  
  def retail_salesman_weekly
    weekly_product_sales
    weekly_article_sales
    weekly_customer_sales
    weekly_city_sales
  end
  
  def retail_salesman_daily
    revenue_this_month_sales
    daily_product_sales
    this_month_article_sales
    this_month_customer_sales
    this_month_city_sales
    this_month_product_sales
    this_week_product_sales
  end
  
  def order_daily
    order_ready_to_ship
    outstanding_order
    held_orders_by_credit
    held_orders_by_approval
  end
  
  def retail_daily
    otd
    revenue_this_month
    daily_summary
    daily_product
    this_month_salesman
    this_month_article
    this_month_customer
    this_month_city
    this_month_product
    this_week_product
  end
  
  def retail_weekly
    last_week_summary_brand
    two_weeks_ago_summary_brand
    three_weeks_ago_summary_brand
    four_weeks_ago_summary_brand
    all_weeks_reports
    this_week_product_summary
    this_week_city_summary
    weekly_channel
  end

  def retail_monthly
    otd
    monthly_salesman_summary
    monthly_article_summary
    monthly_customer_summary
    revenue_last_month
    monthly_summaries
    last_month_city_summary
    this_month_product_summary
  end

  def dashboard
  end
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
  end
end
