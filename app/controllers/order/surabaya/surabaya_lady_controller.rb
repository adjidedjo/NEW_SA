class Order::Surabaya::SurabayaLadyController < ApplicationController
  before_action :initialize_brand, :initialize_brach_id
  before_action :order_daily, only: :order
  
  def order
    @branch = "SURABAYA"
    @brand = "LADY"
    render template: "order/template_order/order"
  end

  private

  def initialize_brand
    "L"
  end

  def initialize_brach_id
    "13061"
  end
end