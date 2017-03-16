class Order::Jember::JemberRoyalController < ApplicationController
  before_action :initialize_brand, :initialize_brach_id
  before_action :order_daily, only: :order
  
  def order
    @branch = "JEMBER"
    @brand = "ROYAL"
    render template: "order/template_order/order"
  end

  private

  def initialize_brand
    "R"
  end

  def initialize_brach_id
    "12132"
  end
end