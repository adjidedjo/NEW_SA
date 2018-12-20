class Order::Semarang::SemarangLadyController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, :authorize_user
  before_action :order_daily, only: :order
  
  def order
    @branch = "SEMARANG"
    @brand = "LADY"
    @pbj = SalesOrder::Order.generate_pbj(initialize_brach_id, initialize_brand) if params["format"] == "xlsx"
    
    respond_to do |format|
      format.html {render template: "order/template_order/order"}
      format.xlsx {render template: "order/template_order/pbj", 
        :xlsx => "pbj", :filename => "pbj #{initialize_brach_id}#{initialize_brand}.xlsx"}
    end
  end

  private

  def initialize_brand
    "L"
  end

  def initialize_brach_id
    "18051"
  end
  
  def authorize_user
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, "LADY") || 
    bm(current_user, 8, "LADY") || sales(current_user, 8, "LADY")
  end
end