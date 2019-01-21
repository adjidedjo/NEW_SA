module OrderDailyConcern
  extend ActiveSupport::Concern
  
  def outstanding_order
    @out_daily = SalesOrder::Order.outstand_order(initialize_brach_id, initialize_brand)
  end
  
  def held_orders_by_credit
    @held_order_credit = SalesOrder::Order.held_orders_by_credit(initialize_brach_id, initialize_brand)
  end
  
  def held_orders_by_approval
    @held_order_approve = SalesOrder::Order.held_orders_by_approval(initialize_brach_id, initialize_brand)
  end
end