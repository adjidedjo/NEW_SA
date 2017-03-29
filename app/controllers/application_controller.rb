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
  helper_method :retail_weekly, :retail_monthly, :retail_daily, :order_daily, 
  :retail_salesman_daily
  
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
