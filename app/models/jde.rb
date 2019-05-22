class Jde < ActiveRecord::Base
  establish_connection :jdeoracle
  self.table_name = "PRODDTA.F0006"
  
  def self.calculate_pbjm(from, to)
    find_by_sql("
      SELECT PF.SDMCU, PF.PBJ, PF.SDSHAN, PF.DES, SUM(PF.TOTAL_PBJM) AS TOTAL, TRIM(PF.WC) AS WC, PF.STAT FROM(
        SELECT PBJ.SDMCU, MAX(SUBSTR(PBJ.SDVR01, 0, 4)) AS PBJ, PBJ.SDSHAN, MAX(ABM.ABALPH) AS DES, SUM(PBJ.SDUORG)/10000 AS TOTAL_PBJM,
        MAX(PBJ.IBSRP6) AS WC, (CASE WHEN PBJ.SDLTTR = 580 THEN 'SENT' ELSE 'OUTS' END) AS STAT FROM (
          SELECT ORD.*, IBC.IBSRP6 FROM(
            SELECT * FROM PRODDTA.F4211
            WHERE SDDRQJ BETWEEN '#{date_to_julian(from)}' AND '#{date_to_julian(to)}' AND SDSRP1 != 'K' AND SDLTTR != '980' AND SDDCTO IN ('SK', 'ST')
            ) ORD
            LEFT OUTER JOIN
            (
              SELECT IBITM, IBSRP6 FROM PRODDTA.F4102 WHERE REGEXP_LIKE(IBMCU, '11001|11002')
              AND IBSRP6 != ' ' GROUP BY IBITM, IBSRP6
            ) IBC ON IBC.IBITM = ORD.SDITM AND ROWNUM = 1
        ) PBJ LEFT JOIN
        (
            SELECT * FROM PRODDTA.F0101 WHERE ABAT1 = 'O'
        ) ABM ON ABM.ABAN8 = PBJ.SDSHAN
        WHERE ABM.ABAT1 = 'O' AND REGEXP_LIKE(PBJ.SDVR01, '^PBJ')
        GROUP BY PBJ.SDMCU, PBJ.SDSHAN, SUBSTR(PBJ.SDVR01, 0, 4), PBJ.SDLTTR
        ORDER BY SDSHAN
      ) PF
      GROUP BY PF.SDMCU, PF.PBJ, PF.SDSHAN, PF.DES, PF.WC, PF.STAT ORDER BY PF.SDSHAN
    ")
  end
  
  def self.get_customer_rkb(customer)
    find_by_sql("SELECT ABALPH FROM PRODDTA.F0101 WHERE ABAN8 LIKE '%#{customer}%' AND ABAT1 = 'C'")
  end

  def self.get_sales_rkb(sales)
    find_by_sql("SELECT ABALPH FROM PRODDTA.F0101 WHERE ABAN8 LIKE '%#{sales}%' AND ABAT1 = 'E'").first
  end
  
  

  private

  def self.date_to_julian(date)
    1000*(date.to_date.year-1900)+date.to_date.yday
  end
end