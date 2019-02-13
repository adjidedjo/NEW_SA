class Jde < ActiveRecord::Base
  establish_connection :jdeoracle
  self.table_name = "PRODDTA.F0006"
  def self.get_customer_rkb(customer)
    find_by_sql("SELECT ABALPH FROM PRODDTA.F0101 WHERE ABAN8 LIKE '%#{customer}%' AND ABAT1 = 'C'")
  end

  def self.get_sales_rkb(sales)
    find_by_sql("SELECT ABALPH FROM PRODDTA.F0101 WHERE ABAN8 LIKE '%#{sales}%' AND ABAT1 = 'E'").first
  end
end