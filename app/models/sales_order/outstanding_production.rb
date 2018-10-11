class SalesOrder::OutstandingProduction < ActiveRecord::Base
  establish_connection :sales_mart
  self.table_name = "BRANCH_PRODUCTIONS"
  def self.get_outstanding
    find_by_sql("
      SELECT item_number, description, segment1, brand, branch, order_in, outstanding_order, buffer, stock_f,
      stock_c, onhand FROM outstanding_productions WHERE branch in (11001, 11002) and
      order_in > 0 and outstanding_order > 0
    ")
  end

  def self.aging_order_calculation(branch)
    find_by_sql("
      SELECT exceeds, day_category, promised_delivery, order_no, last_status, customer, brand, branch, item_number, description, order_date, quantity,
      short_item, segment1, originator FROM PRODUCTION_ORDERS WHERE branch_desc = '#{branch}' and quantity > 0
      AND exceeds > '-4'
    ")
  end
end