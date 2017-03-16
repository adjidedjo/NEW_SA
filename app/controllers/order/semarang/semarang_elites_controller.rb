class Order::Semarang::SemarangElitesController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, :authorize_user
  before_action :order_daily, only: :order
  
  def order
    @branch = "SEMARANG"
    @brand = "ELITE"
    render template: "order/template_order/order"
  end

  private

  def initialize_brand
    "E"
  end

  def initialize_brach_id
    "11051"
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, "ELITE") || 
    bm(current_user, 8, "ELITE") || sales(current_user, 8, "ELITE")
  end
end