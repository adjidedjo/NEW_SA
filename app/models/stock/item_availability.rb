class Stock::ItemAvailability < ActiveRecord::Base
  #establish_connection "jdeoracle".to_sym
  self.table_name = "stocks" #sd

  def self.aging_stock_report(date, branch)
    find_by_sql("
      SELECT branch_plan_desc, brand, grouping,  
  	IFNULL(SUM(CASE WHEN cats = '1-2' THEN quantity END),0) AS 'satu',
  	IFNULL(SUM(CASE WHEN cats = '2-4' THEN quantity END),0) AS 'dua',
	IFNULL(SUM(CASE WHEN cats = '4-6' THEN quantity END),0) AS 'empat',
  	IFNULL(SUM(CASE WHEN cats = '6-12' THEN quantity END),0) AS 'enam',
  	IFNULL(SUM(CASE WHEN cats = '12-24' THEN quantity END),0) AS 'duabelas' ,
  	IFNULL(SUM(CASE WHEN cats = '>730' THEN quantity END),0) AS 'duaempat'
      FROM aging_stock_details WHERE branch_plan like '#{branch}%' GROUP BY brand, grouping ORDER BY branch_plan_desc ASC;
    ")
  end
  
  def self.ledger(from, to, branch)
    find_by_sql("SELECT gabung.item_number, gabung.description, gabung.SO AS keterangan, gabung.order_date, gabung.qty FROM (
      SELECT item_number, description, 'SO', order_date, SUM(quantity) AS qty FROM warehouse.F4211_ORDERS 
      WHERE DATE(order_date) BETWEEN '#{from.to_date}' AND '#{to.to_date}' AND branch = '#{branch}' GROUP BY item_number, DATE(order_date)
        UNION
      SELECT item_number, description, 'PBJ', order_date, SUM(quantity) AS qty FROM warehouse.F4211_ORDERS 
      WHERE DATE(order_date) BETWEEN '#{from.to_date}' AND '#{to.to_date}' AND ship_to = '#{branch}' GROUP BY item_number, DATE(order_date)
        UNION
      SELECT item_number, description, 'STOCK', DATE(created_at) AS order_date, SUM(onhand) AS qty FROM warehouse.F41021_STOCK 
      WHERE DATE(created_at) BETWEEN '#{from.to_date}' AND '#{to.to_date}' AND branch = '#{branch}' GROUP BY item_number, DATE(created_at)
        UNION
      SELECT kodebrg, namabrg, 'SALE', DATE(tanggalsj) AS order_date, SUM(jumlah) AS qty FROM dbmarketing.tblaporancabang     
      WHERE tanggalsj BETWEEN '#{from.to_date}' AND '#{to.to_date}' AND ketppb = '#{branch}' GROUP BY kodebrg, tanggalsj
    ) AS gabung ORDER BY gabung.item_number, gabung.order_date")
  end
  
  def self.stock_report_for_android(branch, brand)
    self.find_by_sql("SELECT onhand, available, description, item_number FROM stocks 
    WHERE branch = '#{branch}' AND brand = '#{brand}' AND product REGEXP 'KM|DV|HB|SA|SB|ST|L|E' AND onhand > 0 ")
  end
  
  def self.recap_cap_stock_report(mat, foam, caps)
    self.find_by_sql("SELECT s.product, bc.capacity,
      SUM(CASE WHEN s.brand = 'ELITE' THEN s.quantity END) AS elite,
      SUM(CASE WHEN s.brand = 'LADY' THEN s.quantity END) AS lady,
      SUM(CASE WHEN s.brand = 'ROYAL' THEN s.quantity END) AS royal,
      SUM(CASE WHEN s.brand = 'SERENITY' THEN s.quantity END) AS serenity
      FROM sales_mart.BRANCH_CAPACITIES s
      LEFT JOIN
      (
        SELECT * FROM branch_capacities
      ) AS bc ON bc.branch = '#{caps}' AND bc.jenis = s.product
      WHERE s.branch = '#{mat}' AND s.quantity > 0 AND DATE(s.created_at) = '#{Date.today}'
      AND s.product IN ('KM','KB','DV','HB') GROUP BY s.product")
  end
  
  def self.stock_report(branch, brand)
    self.find_by_sql("SELECT brand, onhand, available, buffer, description, item_number, updated_at FROM stocks 
    WHERE branch = '#{branch}' AND brand = '#{brand}' AND product REGEXP 'KM|DV|HB|SA|SB|ST|L|E' AND onhand > 0 ")
  end
  
  def self.stock_display_report(branch, brand)
    Jde.find_by_sql("
      SELECT MIN(SO.row_number) as t, MAX(SO.SDDELN) AS NOSJ, MAX(SO.SDDOCO) AS NOSO, MAX(SO.SDMCU) AS BRANCH, SA.LILOTN, 
        NVL(NULLIF(MAX(SO.SDADDJ), 0),MAX(SO.SDDRQJ)) AS ACTUALSHIP, MAX(SO.SDSHAN) AS CUS, MAX(CU.ABALPH) AS CUSTOMER,
        MAX(SO.SDSRP1) AS BRAND, MAX(IT.IMLITM) AS SDLITM, MAX(IT.IMDSC1) AS DESC1, MAX(IT.IMDSC2) AS DESC2, MAX(SA.LIPQOH) AS JML, MAX(CM1.ABALPH) AS SALESMAN,
        SA.LILRCJ AS RECEIVE_DATE
      FROM 
      (
        SELECT LIMCU, MAX(LILOTN) AS LILOTN, SUM(LIPQOH) AS LIPQOH, MAX(LILRCJ) AS LILRCJ, MAX(LIITM) AS LIITM FROM PRODDTA.F41021
        WHERE LIMCU LIKE '%#{branch}%' AND LIPQOH >= 10000 AND LIPBIN = 'S' AND
        LIGLPT LIKE '%#{brand}%' GROUP BY LIMCU, LILOTN
      ) SA
      LEFT JOIN
      (
        SELECT IMITM, IMLITM, IMDSC1, IMDSC2 FROM PRODDTA.F4101
      ) IT ON IT.IMITM = SA.LIITM
      LEFT JOIN
      (
        SELECT * FROM 
        (
          SELECT DISTINCT ROW_NUMBER() OVER (ORDER BY SDADDJ DESC) row_number, SDLOTN, SDDELN, SDDOCO, SDSHAN, SDSRP1, 
                SDUORG, SDDSC1, SDDSC2, SDLITM, SDDRQJ, 
                SDMCU, SDADDJ
                FROM PRODDTA.F4211 WHERE SDDCTO = 'ST' AND SDDELN > 1
          )
      ) SO ON SO.SDLOTN = SA.LILOTN
      LEFT JOIN
      (
        SELECT * FROM PRODDTA.F4301 WHERE PHDCTO = 'OT'
      ) PO ON PO.PHRORN = SO.SDDOCO AND PO.PHMCU LIKE '%#{branch}%'
      LEFT JOIN
      (
        SELECT * FROM PRODDTA.F0101
      ) CU ON CU.ABAN8 = SO.SDSHAN 
      LEFT JOIN
      (
        SELECT SASLSM, SAIT44, SAAN8 FROM PRODDTA.F40344 WHERE SAEXDJ > (select 1000*(to_char(sysdate, 'yyyy')-1900)+to_char(sysdate, 'ddd') as julian from dual)
      ) SM ON SM.SAAN8 = CU.ABAN8 AND SM.SAIT44 = SO.SDSRP1
      LEFT JOIN
      (
        SELECT * FROM PRODDTA.F0101
      ) CM1 ON TRIM(SM.SASLSM) = TRIM(CM1.ABAN8)
      GROUP BY SA.LILOTN, SA.LILRCJ ORDER BY SA.LILRCJ ASC
    ")
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
