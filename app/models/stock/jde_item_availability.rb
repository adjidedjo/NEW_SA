class Stock::JdeItemAvailability < ActiveRecord::Base
  establish_connection :jdeoracle
  self.table_name = "proddta.f41021" #sd
  
  def self.stock_real_jde(artikel, size)
    if artikel.nil? || size.nil?
      
      @stock = find_by_sql("SELECT MAX(IM.imlitm) AS imlitm , 
      CONCAT(CONCAT(MAX(TRIM(TRAILING ' ' FROM IM.imdsc1)), ' '), MAX(TRIM(TRAILING ' ' FROM IM.imdsc2))), 
      IA.liitm AS liitm, IA.limcu AS limcu, SUM(IA.lipqoh/10000) AS lipqoh, SUM(IA.lihcom/10000) AS lihcom
      FROM PRODDTA.F41021 IA JOIN PRODDTA.F4101 IM ON IA.liitm = IM.imitm WHERE limcu LIKE '%18011' 
      AND lipbin = 'S' AND lipqoh > 0 GROUP BY IA.liitm, IA.limcu")
    else
      
    end
    
    render json: {status: "SUCCESS", message: 'Loaded Stock', data_stocks: @stocks}
  end
  
  def self.stock_real_jde_web(branch, brand)
      
      @stock = find_by_sql("SELECT MAX(IM.imlitm) AS item_number, 
      CONCAT(CONCAT(MAX(TRIM(TRAILING ' ' FROM IM.imdsc1)), ' '), MAX(TRIM(TRAILING ' ' FROM IM.imdsc2))) AS description, 
      IA.liitm AS liitm, IA.limcu AS limcu, SUM(IA.lipqoh/10000) AS lipqoh, SUM(IA.lihcom/10000) AS lihcom,
      MAX(IM.imsrp1) AS brand
      FROM PRODDTA.F41021 IA JOIN PRODDTA.F4101 IM ON IA.liitm = IM.imitm WHERE lipbin = 'S' AND lipqoh >= 1 
      AND IM.imsrp1 LIKE '%#{brand}%' AND IA.limcu LIKE '%#{branch}' 
      GROUP BY IA.liitm, IA.limcu")
  end
end