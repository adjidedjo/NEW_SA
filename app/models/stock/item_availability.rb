class Stock::ItemAvailability < ActiveRecord::Base
  establish_connection "jdeoracle".to_sym
  self.table_name = "proddta.f41021" #sd
  
  def self.stock_report(branch, brand)
    self.find_by_sql("SELECT IA.liitm AS liitm, SUM(IA.lipqoh) AS lipqoh, SUM(IA.lihcom) AS lihcom, 
    MAX(IM.imlitm) AS imlitm, MAX(IM.imdsc1) AS imdsc1, MAX(IM.imdsc2) AS imdsc2 FROM PRODDTA.F41021 IA 
    JOIN PRODDTA.F4101 IM ON IA.liitm = IM.imitm
    WHERE IA.limcu LIKE '%#{branch}' AND REGEXP_LIKE(IM.imsrp2,'KM|HB|DV|SA|SB|KB')
    AND IA.lipqoh >= 1 AND IM.imsrp1 LIKE '%#{brand}%'
    GROUP BY IA.liitm, IM.imlitm")
  end
    
end