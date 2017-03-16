class Order::Cirebon::CirebonLadyController < ApplicationController
  before_action :initialize_brand, :initialize_brach_id
  before_action :order_daily, only: :order
  
  def order
    @branch = "CIREBON"
    @brand = "LADY"
    render template: "order/template_order/order"
  end

  private

  def initialize_brand
    "L"
  end

  def initialize_brach_id
    "11021"
  end
end