class SalesOrder::Order < ActiveRecord::Base
  establish_connection "jdeoracle".to_sym
  self.table_name = "proddta.f4211" #sd
  #SDSRP1, SDSRP2, SDUORG
  
  def self.order_summary
  end
  
  def self.outstand_order(branch, brand)
    self.find_by_sql("SELECT DISTINCT so.sddoco, so.sdan8, SUM(so.sduorg), MAX(so.sdshan), 
    MAX(cust.abalph) AS abalph, so.sdopdj
    FROM PRODDTA.F4211 so JOIN PRODDTA.F0101 cust ON so.sdshan = cust.aban8
    JOIN PRODDTA.F4101 itm ON so.sditm = itm.imitm
    WHERE so.sddcto LIKE '%#{'SO'}%' AND so.sdnxtr LIKE '%#{525}%' AND cust.absic LIKE '%RET%' 
    AND so.sdmcu LIKE '%#{branch}%' AND so.sdsrp1 LIKE '%#{brand}%' AND REGEXP_LIKE(so.sdsrp2,'KM|HB|DV|SA|SB|KB')
    AND itm.imseg4 NOT LIKE '%#{'K'}%' GROUP BY so.sddoco, so.sdan8, so.sdopdj")
  end
  
  def self.pick_order(branch, brand)
    self.find_by_sql("SELECT MAX(so.sdopdj) AS sdopdj, so.sddoco, so.sdan8, MAX(so.sdshan), MAX(so.sddrqj), 
    MAX(cust.abalph) AS abalph, MAX(so.sdshan), MAX(cust1.abalph) AS salesman, SUM(so.sduorg) AS jumlah
    FROM PRODDTA.F4211 so
    JOIN PRODDTA.F0101 cust ON so.sdshan = cust.aban8
    JOIN PRODDTA.F40344 sls ON so.sdshan = sls.saan8
    JOIN PRODDTA.F0101 cust1 ON cust1.aban8 = sls.saslsm
    JOIN PRODDTA.F4101 itm ON so.sditm = itm.imitm
    WHERE cust.absic LIKE '%RET%' AND itm.imseg4 NOT LIKE '%#{'K'}%' AND sls.sait44 LIKE '%#{brand}%' 
    AND sls.saexdj > '#{date_to_julian(Date.today.to_date)}' AND sddcto LIKE '%#{'SO'}%' AND 
    so.sdnxtr LIKE '%#{560}%' AND so.sdmcu LIKE '%#{branch}%' AND so.sdsrp1 LIKE '%#{brand}%' 
    AND REGEXP_LIKE(so.sdsrp2,'KM|HB|DV|SA|SB|KB') GROUP BY so.sddoco, so.sdan8")
  end
  
  def self.date_to_julian(date)
    1000*(date.year-1900)+date.yday
  end
end