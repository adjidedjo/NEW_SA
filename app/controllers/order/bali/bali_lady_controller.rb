class Order::Bali::BaliLadyController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, :authorize_user
  before_action :order_daily, only: :order
  
  def order
    @branch = "BALI"
    @brand = "LADY"
    render template: "order/template_order/order"
  end

  private

  def initialize_brand
    "L"
  end

  def initialize_brach_id
    "18071"
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, "LADY") || 
    bm(current_user, 4, "LADY") || sales(current_user, 4, "LADY")
  end
end