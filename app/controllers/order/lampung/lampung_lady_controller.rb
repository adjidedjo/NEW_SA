class Order::Lampung::LampungLadyController < ApplicationController
  before_action :initialize_brand, :initialize_brach_id
  before_action :order_daily, only: :order
  
  def order
    @branch = "LAMPUNG"
    @brand = "LADY"
    render template: "order/template_order/order"
  end

  private

  def initialize_brand
    "L"
  end

  def initialize_brach_id
    "13101"
  end
end