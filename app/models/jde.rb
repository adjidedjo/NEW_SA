class Jde < ActiveRecord::Base
  establish_connection :jdeoracle
  self.table_name = "PRODDTA.F0006"
  def self.calculate_pbjm_cabang(from, to, brand, branch)
    find_by_sql("
      SELECT ADZ.*, IM.IMPRGR AS BRAND, TRIM(JN.JENIS) AS JENIS, (TRIM(ART.TIPE) || ' ' || TRIM(ART.TIPE2)) AS TIPE, TRIM(KA.KAIN) AS KAIN FROM
      (
        SELECT LISTAGG(ORD.NOPBJM, ',') WITHIN GROUP (ORDER BY ORD.SDLITM) AS NOPBJM, MAX(ORD.SDLITM) AS SDLITM, SUM(ORD.TOTAL) AS TOTAL, MAX(ORD.CABANG) AS CABANG,
        MAX(ORD.TANGGALORDER) AS TANGGALORDER, MAX(ORD.KODE) AS KODE, MAX(ORD.NAMABRG1) AS NAMABRG1, MAX(ORD.NAMABRG2) AS NAMABRG2 FROM
            (
              SELECT SDLITM, SUBSTR(SDVR01, 1, 6) AS NOPBJM, MAX(SDSHAN) AS CABANG, MAX(SDTRDJ) AS TANGGALORDER, MAX(SDITM) AS KODE,
                MAX(SDDSC1) AS NAMABRG1, MAX(SDDSC2) AS NAMABRG2, SUM(SDUORG)/10000 AS TOTAL FROM PRODDTA.F4211
                WHERE SDDRQJ BETWEEN '#{date_to_julian(from.to_date)}' AND '#{date_to_julian(to.to_date)}' AND SDSRP1 != 'K'
                  AND SDLTTR != '980' AND SDDCTO IN ('SK', 'ST') AND SDPRP4 != 'RM' AND SDVR01 LIKE 'PBJM%'
                  AND SDVR01 NOT LIKE '%IMG%' AND SDVR01 NOT LIKE '%MM%' AND SDSHAN = '#{branch}'
                  GROUP BY SUBSTR(SDVR01, 1, 6), SDLITM
            ) ORD GROUP BY ORD.SDLITM
      ) ADZ
      LEFT JOIN
        (
         SELECT * FROM PRODDTA.F4101
            ) IM ON IM.IMITM = ADZ.KODE
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
      SELECT MAX(PF.SDMCU) AS SDMCU,
        SUM(CASE WHEN PF.PBJ = 'PBJM' THEN TOTAL_QTY ELSE 0 END) AS TOTAL_PBJM,
        SUM(CASE WHEN PF.PBJ = 'PBJO' THEN TOTAL_QTY ELSE 0 END) AS TOTAL_PBJO,
        SUM(CASE WHEN PF.PBJ = 'PBJM' THEN TOTAL_AMOUNT ELSE 0 END) AS TOTAL_PBJM_AMOUNT,
        SUM(CASE WHEN PF.PBJ = 'PBJO' THEN TOTAL_AMOUNT ELSE 0 END) AS TOTAL_PBJO_AMOUNT,
        TRIM(PF.SDSHAN) AS SDSHAN, PF.DES
      FROM (
        SELECT PBJ.SDMCU, MAX(SUBSTR(PBJ.SDVR01, 0, 4)) AS PBJ, TRIM(PBJ.SDSHAN) AS SDSHAN,
        MAX(ABM.ABALPH) AS DES, SUM(PBJ.SDUORG)/10000 AS TOTAL_QTY,
        SUM(PBJ.SDAEXP) AS TOTAL_AMOUNT FROM (
          SELECT ORD.* FROM(
            SELECT * FROM PRODDTA.F4211
            WHERE SDDRQJ BETWEEN '#{date_to_julian(from)}' AND '#{date_to_julian(to)}' AND SDSRP1 != 'K'
            AND SDLTTR != '980' AND SDDCTO IN ('SK', 'ST') AND SDPRP4 != 'RM' AND SDSRP1 = '#{brand}' 
            AND SDVR01 LIKE 'PBJ%'
            ) ORD
        ) PBJ LEFT JOIN
        (
            SELECT * FROM PRODDTA.F0101 WHERE ABAT1 = 'O'
        ) ABM ON ABM.ABAN8 = PBJ.SDSHAN
        WHERE ABM.ABAT1 = 'O'
        GROUP BY PBJ.SDMCU, PBJ.SDSHAN, SUBSTR(PBJ.SDVR01, 0, 4), PBJ.SDNXTR
        ORDER BY SDSHAN
      ) PF
      GROUP BY PF.SDSHAN, PF.DES ORDER BY PF.SDSHAN
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