class Order::Pekanbaru::PekanbaruRoyalController < ApplicationController
  before_action :initialize_brand, :initialize_brach_id
  before_action :order_daily, only: :order
  
  def order
    @branch = "PEKANBARU"
    @brand = "ROYAL"
    render template: "order/template_order/order"
  end

  private

  def initialize_brand
    "R"
  end

  def initialize_brach_id
    "11122"
  end
end