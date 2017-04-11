class Stock::ItemAvailability < ActiveRecord::Base
  establish_connection "jdeoracle".to_sym
  self.table_name = "proddta.f41021" #sd
  
  def self.stock_report(branch, brand)
    self.find_by_sql("SELECT IA.lipqoh, IA.lihcom, IM.imdsc1, IM.imdsc2 FROM 
    (
     SELECT SUM(lipqoh) AS lipqoh, SUM(lihcom) AS lihcom, liitm FROM PRODDTA.F41021
     WHERE limcu LIKE '%#{branch}' AND lipqoh >= 1 GROUP BY liitm
    ) IA
    LEFT OUTER JOIN PRODDTA.F4101 IM ON IA.liitm = IM.imitm WHERE 
    REGEXP_LIKE(IM.imsrp2,'KM|HB|DV|SA|SB|KB') AND IM.imsrp1 LIKE '%#{brand}%'")
  end
    
end