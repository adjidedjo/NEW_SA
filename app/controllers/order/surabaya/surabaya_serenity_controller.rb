class Order::Surabaya::SurabayaSerenityController < ApplicationController
  before_action :initialize_brand, :initialize_brach_id
  before_action :order_daily
  
  def order
    @branch = "SURABAYA"
    @brand = "SERENITY"
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
    @pbj = SalesOrder::Order.generate_pbj(initialize_brach_id  + "D", initialize_brand) if params["format"] == "xlsx"

    respond_to do |format|
      format.html {render template: "order/template_order/order"}
      format.xlsx {render template: "order/template_order/pbj",
        :xlsx => "pbj", :filename => "pbj #{initialize_brach_id}#{initialize_brand}.xlsx"}
    end
  end
  
  def order_clearence
    @out_daily = SalesOrder::Order.outstand_order(initialize_brach_id  + "C", initialize_brand, current_user.position, current_user.address_number.nil? ? '0' : current_user.address_number)
    @pbj = SalesOrder::Order.generate_pbj(initialize_brach_id  + "C", initialize_brand) if params["format"] == "xlsx"

    respond_to do |format|
      format.html {render template: "order/template_order/order"}
      format.xlsx {render template: "order/template_order/pbj",
        :xlsx => "pbj", :filename => "pbj #{initialize_brach_id}#{initialize_brand}.xlsx"}
    end
  end

  private

  def initialize_brand
    "S|C"
  end

  def initialize_brach_id
    "12061"
  end
end