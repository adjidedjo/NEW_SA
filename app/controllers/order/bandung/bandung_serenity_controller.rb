class Order::Bandung::BandungSerenityController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, :authorize_user
  before_action :order_daily, only: :order
  
  def order
    @branch = "BANDUNG"
    @brand = "SERENITY"
    render template: "order/template_order/order"
  end

  private

  def initialize_brand
    "S"
  end

  def initialize_brach_id
    "11011"
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, "SERENITY") || 
    bm(current_user, 2, "SERENITY") || sales(current_user, 2, "SERENITY")
  end
end