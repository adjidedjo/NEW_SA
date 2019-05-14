class Order::Bandung::BandungLadyController < ApplicationController
  include RolesHelper
  before_action :initialize_brand, :initialize_brach_id, :authorize_users
  before_action :order_daily, only: :order
  
  def order
    @branch = "BANDUNG"
    @brand = "LADY"
    @pbj = SalesOrder::Order.generate_pbj(initialize_brach_id, initialize_brand) if params["format"] == "xlsx"
    
    respond_to do |format|
      format.html {render template: "order/template_order/order"}
      format.xlsx {render template: "order/template_order/pbj", 
        :xlsx => "pbj", :filename => "pbj #{initialize_brach_id}#{initialize_brand}.xlsx"}
    end
    
  end
  
  def order_normal
    @out_daily = SalesOrder::Order.outstand_order(initialize_brach_id, initialize_brand, current_user.position, current_user.address_number.nil? ? '0' : current_user.address_number)
    @pbj = SalesOrder::Order.generate_pbj(initialize_brach_id, initialize_brand) if params["format"] == "xlsx"
    
    respond_to do |format|
      format.html {render template: "order/template_order/order"}
      format.xlsx {render template: "order/template_order/pbj", 
        :xlsx => "pbj", :filename => "pbj #{initialize_brach_id}#{initialize_brand}.xlsx"}
    end
  end
  
  def order_display
    @out_daily = SalesOrder::Order.outstand_order(initialize_brach_id  + "D", initialize_brand, current_user.position, current_user.address_number.nil? ? '0' : current_user.address_number)
    
    respond_to do |format|
      format.html {render template: "order/template_order/order"}
    end
  end
  
  def order_clearence
    @out_daily = SalesOrder::Order.outstand_order(initialize_brach_id  + "C", initialize_brand, current_user.position, current_user.address_number.nil? ? '0' : current_user.address_number)
    
    respond_to do |format|
      format.html {render template: "order/template_order/order"}
    end
  end

  private

  def initialize_brand
    "L"
  end

  def initialize_brach_id
    "18011"
  end
  
  def authorize_users
    render template: "pages/notfound" unless general_manager(current_user) || nsm(current_user, "LADY") || 
    bm(current_user, 2, "LADY") || sales(current_user, 2, "LADY")
  end
end