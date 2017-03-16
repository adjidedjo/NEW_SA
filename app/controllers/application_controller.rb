class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  include PenjualanConcern
  include PenjualanDailyConcern
  include OrderDailyConcern
  helper_method :retail_weekly, :retail_monthly, :retail_daily, :order_daily
  
  def order_daily
    order_ready_to_ship
    outstanding_order
  end
  
  def retail_daily
    daily_summary
    product_daily
    daily_summary_data
    customer_daily
    salesman_daily
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
    last_month_city_summary
    last_month_summary_brand
    two_month_ago_summary_brand
    three_month_ago_summary_brand
    four_month_ago_summary_brand
    all_months_reports
    this_month_product_summary
    monthly_channel
  end

  def dashboard
  end
  
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
  end
end
