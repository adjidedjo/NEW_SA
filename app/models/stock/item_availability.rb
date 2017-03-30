class Stock::ItemAvailability < ActiveRecord::Base
  establish_connection "jdeoracle".to_sym
  self.table_name = "proddta.f41021" #sd
  
  def self.stock_report(branch, brand)
    self.find_by_sql("SELECT IA.liitm AS liitm, SUM(IA.lipqoh) AS lipqoh, SUM(IA.lihcom) AS lihcom, 
    IM.imlitm, IM.imdsc1, IM.imdsc2 FROM PRODDTA.F41021 IA 
    JOIN PRODDTA.F4101 IM ON IA.liitm = IM.imitm
    WHERE IA.limcu LIKE '%#{branch}' 
    AND IA.lipqoh >= 1 AND IM.imsrp1 LIKE '%#{brand}%'
    GROUP BY IA.liitm, IM.imlitm, IM.imdsc1, IM.imdsc2")
  end
    
end