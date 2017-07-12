class SalesProductivityReport < ActiveRecord::Base
  
  def self.report(branch, brand)
    self.find_by_sql("SELECT spr.*, COALESCE(usr.nama,'Total') AS nama_sales FROM 
    ( 
     SELECT * FROM sales_productivity_reports WHERE branch_id = '#{branch}' AND 
     brand = '#{brand}'
    ) AS spr
    LEFT JOIN
    (
     SELECT id, nama FROM salesmen
    ) AS usr ON usr.id = spr.salesmen_id")
  end
end
