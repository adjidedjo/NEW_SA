class Stock::JdeItemAvailability < ActiveRecord::Base
  establish_connection :jdeoracle
  self.table_name = "PRODDTA.F41021" #sd
  
  def self.stock_real_jde(artikel, size)
    if artikel.nil? || size.nil?
      
      @stock = find_by_sql("SELECT
      MAX(IM.imdsc1) AS description, MAX(IM.imseg4) AS seg4, MAX(IM.imseg5) AS panjang, 
      SUM(CASE WHEN IM.imseg6 = '090' THEN (IA.lipqoh - IA.lihcom)/10000 END) as A90,
      SUM(CASE WHEN IM.imseg6 = '100' THEN (IA.lipqoh - IA.lihcom)/10000 END) as A100,
      SUM(CASE WHEN IM.imseg6 = '120' THEN (IA.lipqoh - IA.lihcom)/10000 END) as A120,
      SUM(CASE WHEN IM.imseg6 = '160' THEN (IA.lipqoh - IA.lihcom)/10000 END) as A160,
      SUM(CASE WHEN IM.imseg6 = '180' THEN (IA.lipqoh - IA.lihcom)/10000 END) as A180,
      SUM(CASE WHEN IM.imseg6 = '200' THEN (IA.lipqoh - IA.lihcom)/10000 END) as A200,
      MAX(IM.imsrp1) AS brand
      FROM PRODDTA.F41021 IA 
      JOIN PRODDTA.F4101 IM ON IA.liitm = IM.imitm
      WHERE limcu LIKE '%18011' AND lipbin = 'S' AND lipqoh > 0 
      GROUP BY IM.imseg2, IM.imseg3, IM.imseg5")
    else
      
    end
    
    render json: {status: "SUCCESS", message: 'Loaded Stock', data_stocks: @stocks}
  end
  
  def self.stock_real_jde_web(branch, brand)
      
      @stock = find_by_sql("SELECT
      MAX(IM.imdsc1) AS dsc1, MAX(IM.imdsc2) AS dsc2, MAX(IM.imseg4) AS seg4, MAX(IM.imseg5) AS panjang, 
      MAX(IM.imseg6) AS lebar,
      NVL(SUM(CASE WHEN IM.imseg6 = '090' THEN (IA.lipqoh - IA.lihcom)/10000 END),0) as AA,
      NVL(SUM(CASE WHEN IM.imseg6 = '100' THEN (IA.lipqoh - IA.lihcom)/10000 END),0) as AB,
      NVL(SUM(CASE WHEN IM.imseg6 = '120' THEN (IA.lipqoh - IA.lihcom)/10000 END),0) as AC,
      NVL(SUM(CASE WHEN IM.imseg6 = '140' THEN (IA.lipqoh - IA.lihcom)/10000 END),0) as AD,
      NVL(SUM(CASE WHEN IM.imseg6 = '160' THEN (IA.lipqoh - IA.lihcom)/10000 END),0) as AE,
      NVL(SUM(CASE WHEN IM.imseg6 = '180' THEN (IA.lipqoh - IA.lihcom)/10000 END),0) as AF,
      NVL(SUM(CASE WHEN IM.imseg6 = '200' THEN (IA.lipqoh - IA.lihcom)/10000 END),0) as AG,
      NVL(SUM(CASE WHEN IM.imseg6 NOT IN ('090', '100', '120', '140', '160', '180', '200') THEN (IA.lipqoh - IA.lihcom)/10000 END),0) as AH,
      MAX(IM.imsrp1) AS brand
      FROM PRODDTA.F41021 IA 
      JOIN PRODDTA.F4101 IM ON IA.liitm = IM.imitm
      WHERE lipqoh >= 1 
      AND IM.imsrp1 LIKE '%#{brand}%' AND IA.limcu LIKE '%#{branch}' 
      GROUP BY IM.imseg2, IM.imseg3, IM.imseg5, IM.imseg6")
  end
end