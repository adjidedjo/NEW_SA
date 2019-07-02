class Jde < ActiveRecord::Base
  establish_connection :jdeoracle
  self.table_name = "PRODDTA.F0006"
  def self.calculate_pbjm(from, to)
    find_by_sql("
      SELECT PF.SDMCU, PF.PBJ, TRIM(PF.SDSHAN) AS SDSHAN, PF.DES, SUM(PF.TOTAL_PBJM) AS TOTAL, PF.STAT FROM(
        SELECT PBJ.SDMCU, MAX(SUBSTR(PBJ.SDVR01, 0, 4)) AS PBJ, TRIM(PBJ.SDSHAN) AS SDSHAN, MAX(ABM.ABALPH) AS DES, SUM(PBJ.SDUORG)/10000 AS TOTAL_PBJM,
        (CASE WHEN PBJ.SDLTTR >= 580 THEN 'SENT' ELSE 'OUTS' END) AS STAT FROM (
          SELECT ORD.* FROM(
            SELECT * FROM PRODDTA.F4211
            WHERE REGEXP_LIKE(SDSRP2, 'KM|DV|HB|SA|ST|SB|KB') AND SDDRQJ BETWEEN '#{date_to_julian(from)}' AND '#{date_to_julian(to)}' AND SDSRP1 != 'K'
            AND SDLTTR != '980' AND SDDCTO IN ('SK', 'ST') AND SDPRP4 != 'RM' AND REGEXP_LIKE(SDVR01, '^PBJ')
            ) ORD
        ) PBJ LEFT JOIN
        (
            SELECT * FROM PRODDTA.F0101 WHERE ABAT1 = 'O'
        ) ABM ON ABM.ABAN8 = PBJ.SDSHAN
        WHERE ABM.ABAT1 = 'O'
        GROUP BY PBJ.SDMCU, PBJ.SDSHAN, SUBSTR(PBJ.SDVR01, 0, 4), PBJ.SDLTTR
        ORDER BY SDSHAN
      ) PF
      GROUP BY PF.SDMCU, PF.PBJ, PF.SDSHAN, PF.DES, PF.STAT ORDER BY PF.SDSHAN
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