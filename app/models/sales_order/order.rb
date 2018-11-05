class SalesOrder::Order < ActiveRecord::Base
  #establish_connection "dbmarketing".to_sym
  self.table_name = "sales_outstanding_orders" #sd
  #SDSRP1, SDSRP2, SDUORG
  #HELD ORDRES TABLE (HO)
  
  def self.generate_pbj(branch, brand)
    Jde.find_by_sql("
      SELECT BO.SDITM, BO.SDLITM AS ITEM_NUMBER, BO.SDMCU AS BRANCH_PLAN, BO.SO_REQDATE, IB.SAFETY/10000 AS SAFETY_STOCK, BO.QTY/10000 AS QTY_ORDER, 
      NVL(ST.ONHAND/10000,0) AS ONHAND, NVL(ST.COMIT/10000, 0) AS COMIT, NVL(PO.QTY/10000, 0) AS QTY_PBJ,
      CONCAT(CONCAT(TRIM(BO.SDDSC1), ' '), TRIM(BO.SDDSC2)) AS DESCRIPTION,
      NVL(PO.SDMCU, '-') AS PBJ_BP, NVL(PO.PO_PROMISE, 0) AS PO_PROMISEDATE, NVL(PO.CUSTOMER_PO, '-') AS CUSTOMER_PO FROM
      (
        SELECT SDITM, MAX(SDLITM) AS SDLITM, SDMCU, SUM(SDUORG) AS QTY, MIN(SDDRQJ) AS SO_REQDATE, MAX(SDDSC1) AS SDDSC1, MAX(SDDSC2) AS SDDSC2 FROM PRODDTA.F4211 
        WHERE SDNXTR = '525' AND SDMCU LIKE '%#{branch}' AND SDSRP1 LIKE '#{brand}%'
        GROUP BY SDITM, SDMCU
      ) BO
      LEFT JOIN
      (
        SELECT IBITM, IBMCU, SUM(IBSAFE) AS SAFETY FROM PRODDTA.F4102 GROUP BY IBITM, IBMCU
      ) IB ON IB.IBITM = BO.SDITM AND IB.IBMCU = BO.SDMCU
      LEFT JOIN
      (
        SELECT LIITM, LIMCU, SUM(LIPQOH) AS ONHAND, SUM(LIHCOM) AS COMIT FROM PRODDTA.F41021 
        WHERE LIMCU LIKE '%18011' AND LIPQOH > 0 GROUP BY LIITM, LIMCU
      ) ST ON ST.LIITM = BO.SDITM AND ST.LIMCU = BO.SDMCU
      LEFT JOIN
      (
        SELECT SDMCU, SDITM, MAX(SDLITM) AS SDLITM, SDSHAN, SUM(SDUORG) AS QTY, MAX(SDDRQJ) AS PO_PROMISE, MIN(SDVR01) AS CUSTOMER_PO FROM PRODDTA.F4211 WHERE SDNXTR = '525' 
        AND REGEXP_LIKE(SDKCOO, '11000|12000|15000') 
        GROUP BY SDITM, SDSHAN, SDMCU
      ) PO ON BO.SDITM = PO.SDITM AND BO.SDMCU = PO.SDSHAN
    ")
  end
  
  def self.held_orders_by_approval(branch, brand)
    find_by_sql("SELECT * FROM hold_orders WHERE hdcd = 'C2' AND branch = '#{branch}' AND brand = '#{brand}' 
    AND updated_at >= '#{Date.today}'")
  end
  
  def self.held_orders_by_credit(branch, brand)
    find_by_sql("SELECT * FROM hold_orders WHERE hdcd = 'C1' AND branch = '#{branch}' AND brand = '#{brand}'
    AND updated_at >= '#{Date.today}'")
  end
  
  def self.order_summary
  end
  
  def self.outstand_order(branch, brand)
    find_by_sql("SELECT * FROM warehouse.F4211_ORDERS WHERE branch LIKE '#{branch}%' AND brand = '#{brand}'
    AND updated_at >= '#{Date.today}' AND next_status = 525")
  end
  
  def self.pick_order(branch, brand)
    find_by_sql("SELECT * FROM outstanding_shipments WHERE branch = '#{branch}' AND brand = '#{brand}'
    AND updated_at >= '#{Date.today}'")
  end
  
  private
  
  def self.positive_checking(val)
    val > 1 ? 0 : val 
  end
  
  def self.date_to_julian(date)
    1000*(date.year-1900)+date.yday
  end
  
  def self.julian_to_date(jd_date)
    if jd_date.nil? || jd_date == 0
      0
    else
      Date.parse((jd_date+1900000).to_s, 'YYYYYDDD').strftime("%d/%m/%Y")
    end
  end
end