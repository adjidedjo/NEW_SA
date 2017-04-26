class Stock::ItemAvailability < ActiveRecord::Base
  #establish_connection "jdeoracle".to_sym
  self.table_name = "stocks" #sd
  
  def self.stock_report(branch, brand)
    self.find_by_sql("SELECT onhand, available, buffer, description, item_number, updated_at FROM stocks WHERE 
    branch = '#{branch}' AND brand = '#{brand}'")
  end
    
end