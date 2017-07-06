class SalesOrder::Order < ActiveRecord::Base
  #establish_connection "dbmarketing".to_sym
  self.table_name = "outstanding_orders" #sd
  #SDSRP1, SDSRP2, SDUORG
  #HELD ORDRES TABLE (HO)
  
  def self.held_orders_by_approval(branch, brand)
    find_by_sql("SELECT * FROM hold_orders WHERE hdcd = 'C2' AND branch = '#{branch}' AND brand = '#{brand}' 
    AND updated_at >= '#{Date.today}'")
  end
  
  def self.held_orders_by_credit(branch, brand)
    find_by_sql("SELECT * FROM hold_orders WHERE hdcd = 'C1' AND branch = '#{branch}' AND brand = '#{brand}'
    AND updated_at >= '#{Date.today}'")
  end
  
  def self.order_summary
  end
  
  def self.outstand_order(branch, brand)
    find_by_sql("SELECT * FROM outstanding_orders WHERE branch = '#{branch}' AND brand = '#{brand}'
    AND updated_at >= '#{Date.today}'")
  end
  
  def self.pick_order(branch, brand)
    find_by_sql("SELECT * FROM outstanding_shipments WHERE branch = '#{branch}' AND brand = '#{brand}'
    AND updated_at >= '#{Date.today}'")
  end
  
  def self.date_to_julian(date)
    1000*(date.year-1900)+date.yday
  end
end