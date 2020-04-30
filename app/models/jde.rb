class Jde < ActiveRecord::Base
  establish_connection :jdeoracle
  self.table_name = "PRODDTA.F0006"
  
  def self.calculate_pbjm_cabang(from, to, brand, branch)
    find_by_sql("
      SELECT ORD.*, IM.IMPRGR AS BRAND, TRIM(JN.JENIS) AS JENIS, (TRIM(ART.TIPE) || ' ' || TRIM(ART.TIPE2)) AS TIPE, TRIM(KA.KAIN) AS KAIN FROM
      (
        SELECT SDSHAN AS CABANG, MAX(SDTRDJ) AS TANGGALORDER, MAX(SDVR01) AS NOPBJM, SDLITM, MAX(SDITM) AS KODE,
          MAX(SDDSC1) AS NAMABRG1, MAX(SDDSC2) AS NAMABRG2, SUM(SDUORG)/10000 AS TOTAL FROM PRODDTA.F4211
          WHERE REGEXP_LIKE(SDSRP2, 'KM|DV|HB|SA|ST|SB|KB') AND SDDRQJ BETWEEN '120111' AND '120117' AND SDSRP1 != 'K'
          AND SDLTTR != '980' AND SDDCTO IN ('SK', 'ST') AND SDPRP4 != 'RM' AND SDVR01 LIKE 'PBJM%'
          AND SDVR01 NOT LIKE '%IMG%' AND SDVR01 NOT LIKE '%MM%' AND SDSHAN = '#{branch}'
          GROUP BY SDSHAN, SDLITM, SDSRP1
      ) ORD
      LEFT JOIN
      (
        SELECT * FROM PRODDTA.F4101
      ) IM ON IM.IMITM = ORD.KODE
      LEFT JOIN
       (
       SELECT DRKY AS JENIS FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = 'JN'
       ) JN ON JN.JENIS LIKE '%'||TRIM(IM.IMSEG1)
       LEFT JOIN
       (
       SELECT DRDL01 AS TIPE, DRDL02 AS TIPE2, DRKY AS JENIS FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = 'AT'
       ) ART ON ART.JENIS LIKE '%'||TRIM(IM.IMSEG2)
       LEFT JOIN
       (
       SELECT DRKY, DRDL01 AS KAIN FROM PRODCTL.F0005 WHERE DRSY = '55' AND DRRT = 'KA'
       ) KA ON KA.DRKY LIKE '%'||TRIM(IM.IMSEG3)
    ")
  end

  def self.calculate_pbjm(from, to, brand)
    brand = brand.at(0)
    find_by_sql("
      SELECT MAX(PF.SDMCU) AS SDMCU, PF.PBJ, TRIM(PF.SDSHAN) AS SDSHAN, PF.DES, SUM(PF.TOTAL_PBJM) AS TOTAL,
      PF.STATUS AS STATUS FROM(
        SELECT PBJ.SDMCU, MAX(SUBSTR(PBJ.SDVR01, 0, 4)) AS PBJ, TRIM(PBJ.SDSHAN) AS SDSHAN,
        MAX(ABM.ABALPH) AS DES, SUM(PBJ.SDUORG)/10000 AS TOTAL_PBJM,
        (CASE WHEN PBJ.SDNXTR IN (525) THEN 'ORDER'
        WHEN PBJ.SDNXTR IN (540, 560) THEN 'PICK'
        WHEN PBJ.SDNXTR IN (580, 999) THEN 'DELIVERED' END) AS STATUS FROM (
          SELECT ORD.* FROM(
            SELECT * FROM PRODDTA.F4211
            WHERE REGEXP_LIKE(SDSRP2, 'KM|DV|HB|SA|ST|SB|KB') AND SDDRQJ BETWEEN '#{date_to_julian(from)}' AND '#{date_to_julian(to)}' AND SDSRP1 != 'K'
            AND SDLTTR != '980' AND SDDCTO IN ('SK', 'ST') AND SDPRP4 != 'RM' AND SDSRP1 = '#{brand}' AND SDVR01 LIKE 'PBJ%'
            ) ORD
        ) PBJ LEFT JOIN
        (
            SELECT * FROM PRODDTA.F0101 WHERE ABAT1 = 'O'
        ) ABM ON ABM.ABAN8 = PBJ.SDSHAN
        WHERE ABM.ABAT1 = 'O'
        GROUP BY PBJ.SDMCU, PBJ.SDSHAN, SUBSTR(PBJ.SDVR01, 0, 4), PBJ.SDNXTR
        ORDER BY SDSHAN
      ) PF
      GROUP BY PF.SDSHAN, PF.PBJ, PF.DES, PF.STATUS ORDER BY PF.SDSHAN
    ")
  end

  def self.get_customer_rkb(customer)
    find_by_sql("SELECT ABALPH FROM PRODDTA.F0101 WHERE ABAN8 LIKE '%#{customer}%' AND ABAT1 = 'C'").first
  end

  def self.get_sales_rkb(sales)
    find_by_sql("SELECT ABALPH FROM PRODDTA.F0101 WHERE ABAN8 LIKE '%#{sales}%' AND ABAT1 = 'E'").first
  end

  private

  def self.date_to_julian(date)
    1000*(date.to_date.year-1900)+date.to_date.yday
  end
end