module OrderDailyConcern
  extend ActiveSupport::Concern
  
  def outstanding_order
    @out_daily = SalesOrder::Order.outstand_order(initialize_brach_id, initialize_brand)
  end
  
  def order_ready_to_ship
    @pick_daily = SalesOrder::Order.pick_order(initialize_brach_id, initialize_brand)
  end
end