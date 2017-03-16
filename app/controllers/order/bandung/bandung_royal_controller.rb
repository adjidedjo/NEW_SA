class Order::Bandung::BandungRoyalController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, :authorize_user
  before_action :order_daily, only: :order
  
  def order
    @branch = "BANDUNG"
    @brand = "ROYAL"
    render template: "order/template_order/order"
  end

  private

  def initialize_brand
    "R"
  end

  def initialize_brach_id
    "11002"
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, "ROYAL") || 
    bm(current_user, 2, "ROYAL") || sales(current_user, 2, "ROYAL")
  end
end