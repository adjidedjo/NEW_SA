class Stock::ItemAvailability < ActiveRecord::Base
  #establish_connection "jdeoracle".to_sym
  self.table_name = "stocks" #sd
  
  def self.stock_report_for_android(branch, brand)
    self.find_by_sql("SELECT onhand, available, description, item_number FROM stocks 
    WHERE branch = '#{branch}' AND brand = '#{brand}' AND product REGEXP 'KM|DV|HB|SA|SB|ST|L|E' AND onhand > 0 ")
  end
  
  def self.recap_cap_stock_report(mat, foam, caps)
    self.find_by_sql("SELECT s.product, bc.capacity,
      SUM(CASE WHEN s.brand = 'E' THEN s.onhand END) AS elite,
      SUM(CASE WHEN s.brand = 'L' THEN s.onhand END) AS lady,
      SUM(CASE WHEN s.brand = 'R' THEN s.onhand END) AS royal,
      SUM(CASE WHEN s.brand = 'S' THEN s.onhand END) AS serenity
      FROM stocks s
      LEFT JOIN
      (
        SELECT * FROM branch_capacities
      ) AS bc ON bc.branch = '#{caps}' AND bc.jenis = s.product
      WHERE s.branch IN ('#{mat}', '#{foam}') AND s.onhand > 0 
      AND s.status IN ('N') AND s.product IN ('KM','KB','DV','HB') GROUP BY s.product")
  end
  
  def self.stock_report(branch, brand)
    self.find_by_sql("SELECT brand, onhand, available, buffer, description, item_number, updated_at FROM stocks 
    WHERE branch = '#{branch}' AND brand = '#{brand}' AND product REGEXP 'KM|DV|HB|SA|SB|ST|L|E' AND onhand > 0 ")
  end
  
  def self.stock_display_report(branch, brand)
    find_by_sql("SELECT onhand, available, description, item_number, customer, age, updated_at FROM display_stocks 
    WHERE branch = '#{branch}' AND brand = '#{brand}' AND onhand > 0 GROUP BY item_number, customer")
  end
  
  def self.recap_stock_report(branch, brand)
    self.find_by_sql("SELECT product, status, COALESCE(status, 'TOTAL') AS status,
      SUM(CASE WHEN product = 'KM' THEN onhand END) AS km,
      SUM(CASE WHEN product = 'DV' THEN onhand END) AS dv,
      SUM(CASE WHEN product = 'HB' THEN onhand END) AS hb,
      SUM(CASE WHEN product = 'SA' THEN onhand END) AS sa,
      SUM(CASE WHEN product = 'SB' THEN onhand END) AS sb,
      SUM(CASE WHEN product = 'ST' THEN onhand END) AS st,
      SUM(CASE WHEN product = 'KB' THEN onhand END) AS kb
      FROM stocks
      WHERE branch LIKE '#{branch}%' AND brand = '#{brand}' AND onhand > 0 
      AND status IN ('N','S','D','C') GROUP BY status WITH ROLLUP")
  end
  
  def self.recap_display_stock_report(branch, brand)
    self.find_by_sql("SELECT product, customer, COALESCE(customer, 'Z TOTAL DISPLAY STOCK') AS customer,
      SUM(CASE WHEN product = 'KM' THEN onhand END) AS km,
      SUM(CASE WHEN product = 'DV' THEN onhand END) AS dv,
      SUM(CASE WHEN product = 'HB' THEN onhand END) AS hb,
      SUM(CASE WHEN product = 'SA' THEN onhand END) AS sa,
      SUM(CASE WHEN product = 'SB' THEN onhand END) AS sb,
      SUM(CASE WHEN product = 'ST' THEN onhand END) AS st,
      SUM(CASE WHEN product = 'KB' THEN onhand END) AS kb
      FROM display_stocks
      WHERE branch LIKE '#{branch}%' AND brand = '#{brand}' AND onhand > 0 
      AND status IN ('N','S','D','C') GROUP BY customer WITH ROLLUP")
  end
    
end