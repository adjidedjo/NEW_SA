class Order::Pusat::PusatElitesController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id
  
  def order
    @branch = "PUSAT"
    @brand = "ELITE"
    @pbj = SalesOrder::Order.generate_pbj(initialize_brach_id, initialize_brand)
    
    respond_to do |format|
      format.html {render template: "order/template_order/order"}
    end
  end

  private

  def initialize_brand
    "E"
  end

  def initialize_brach_id
    "11001"
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, "ELITE") || 
    bm(current_user, 2, "ELITE") || sales(current_user, 2, "ELITE")
  end
end