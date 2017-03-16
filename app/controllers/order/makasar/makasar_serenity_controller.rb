class Order::Makasar::MakasarSerenityController < ApplicationController
  before_action :initialize_brand, :initialize_brach_id
  before_action :order_daily, only: :order
  
  def order
    @branch = "MAKASAR"
    @brand = "SERENITY"
    render template: "order/template_order/order"
  end

  private

  def initialize_brand
    "S"
  end

  def initialize_brach_id
    "12111"
  end
end