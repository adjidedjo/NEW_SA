class Forecast < ActiveRecord::Base

  def self.calculation_forecasts_by_branch_and_sales(start_date, end_date, area)
    self.find_by_sql("
      SELECT oa.nopo, oa.salesman, oa.jenisbrgdisc AS brand, SUM(oa.quantity) AS quantity, SUM(oa.jumlah) AS jumlah,
      SUM(oa.acv) AS acv, SUM(oa.todate) AS todate, SUM(IFNULL(equal_sales,0)) AS equal_sales,
      SUM(IFNULL(more_sales,0)) AS more_sales, SUM(IFNULL(less_sales,0)) AS less_sales,
      SUM(IFNULL(more_sales_for_non,0)) AS msfn FROM
      (
            SELECT f1.nopo, f1.salesman, lp.kodebrg, f.todate, IFNULL(lp.jenisbrgdisc, f.brand) AS jenisbrgdisc, lp.namabrg, a.area,
            f.branch, f.size, f.quantity, lp.jumlah, ABS((IFNULL(lp.jumlah,0)-IFNULL(f.todate,0))) AS acv,
            CASE WHEN IFNULL(lp.jumlah,0) = IFNULL(f.todate, 0) THEN lp.jumlah END AS equal_sales,
            CASE WHEN IFNULL(lp.jumlah,0) > IFNULL(f.todate,0) THEN f.todate END AS more_sales,
            CASE WHEN IFNULL(lp.jumlah,0) < IFNULL(f.todate,0) THEN lp.jumlah END AS less_sales,
            CASE WHEN IFNULL(lp.jumlah,0) > IFNULL(f.todate,0) THEN
            (IFNULL(lp.jumlah,0) - IFNULL(f.todate,0)) END AS more_sales_for_non
            FROM
            (
              SELECT DISTINCT(kodebrg), nopo, salesman FROM
              tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
              ('KM', 'DV', 'HB', 'KB', 'SB', 'SA', 'ST')  AND tanggalsj BETWEEN '#{start_date.to_date}'
              AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc NOT LIKE 'CLASSIC'

              UNION ALL

              SELECT DISTINCT(item_number), address_number, sales_name FROM
              forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
              '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}'
              AND '#{end_date.to_date.year}' AND branch = '#{area}'
            ) AS f1
            LEFT JOIN
            (
              SELECT SUM(jumlah) AS jumlah, jenisbrgdisc, kodebrg, namabrg, area_id, nopo, fiscal_month, fiscal_year FROM
              tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
              ('KM', 'DV', 'HB', 'KB', 'SB', 'SA', 'ST')  AND tanggalsj
              BETWEEN '#{start_date.to_date}' AND '#{end_date.to_date}' AND area_id = '#{area}'
              AND jenisbrgdisc NOT LIKE 'CLASSIC'
              GROUP BY nopo, kodebrg
            ) AS lp ON lp.kodebrg = f1.kodebrg and (lp.nopo = f1.nopo)
            LEFT JOIN
            (
              SELECT address_number, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
              segment3_name, size, SUM(quantity) AS quantity,
              ROUND((SUM(quantity)/DAY(LAST_DAY('#{end_date.to_date}')))*DAY('#{end_date.to_date}')) AS todate FROM
              forecasts WHERE branch = '#{area}' AND MONTH BETWEEN '#{start_date.to_date.month}' AND
              '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
              GROUP BY address_number, item_number
            ) AS f ON f.item_number = f1.kodebrg and (f.address_number = f1.nopo)
            LEFT JOIN
            (
              SELECT * FROM areas
            ) AS a ON f.branch = a.id
      GROUP BY f1.kodebrg
      ) AS oa GROUP BY oa.nopo, oa.jenisbrgdisc
    ")
  end

  def self.score_card(branch)
    find_by_sql("SELECT f.address_number , f.sales_name , f.segment2_name, f.brand, f.segment3_name,
      SUM(CASE WHEN f.`size` = 000 then f.quantity else 0 end) satu ,
      SUM(CASE WHEN f.`size` = 100 then f.quantity else 0 end) dua ,
      SUM(CASE WHEN f.`size` = 120 then f.quantity else 0 end) tiga ,
      SUM(CASE WHEN f.`size` = 140 then f.quantity else 0 end) empat ,
      SUM(CASE WHEN f.`size` = 160 then f.quantity else 0 end) lima ,
      SUM(CASE WHEN f.`size` = 180 then f.quantity else 0 end) enam ,
      SUM(CASE WHEN f.`size` = 200 then f.quantity else 0 end) tujuh ,
      SUM(CASE WHEN rs.lebar = 000 then rs.total else 0 end) rea1 ,
      SUM(CASE WHEN rs.lebar = 100 then rs.total else 0 end) rea2 ,
      SUM(CASE WHEN rs.lebar = 120 then rs.total else 0 end) rea3 ,
      SUM(CASE WHEN rs.lebar = 140 then rs.total else 0 end) rea4 ,
      SUM(CASE WHEN rs.lebar = 160 then rs.total else 0 end) rea5 ,
      SUM(CASE WHEN rs.lebar = 180 then rs.total else 0 end) rea6 ,
      SUM(CASE WHEN rs.lebar = 200 then rs.total else 0 end) rea7 ,
      SUM(f.quantity) total_forecast, SUM(rs.total) total_realisasi
    FROM forecasts f 
    INNER JOIN 
    (
      SELECT item_number, panjang, lebar, nopo, MAX(salesman) as salesman, sum(total) as total 
	  from sales_mart.RET3SALITEMNUMBER rs 
      where month = 10 and year = 2022 group by item_number, panjang, lebar, nopo
    ) rs on f.address_number = address_number AND (f.item_number = rs.item_number)
    WHERE f.`month`  = 10 and f.`year` = 2022 and f.branch = 2 and f.brand is not null
    GROUP BY f.address_number , f.sales_name, f.brand , f.segment2_name, f.segment3, f.segment3_name
    ORDER BY f.address_number ASC").group_by(&:sales_name)
  end

  def self.score_card_salesman(branch)
    find_by_sql("SELECT f.address_number , f.sales_name , f.segment2_name, f.brand, f.segment3_name,
      SUM(CASE WHEN f.`size` = 000 then f.quantity else 0 end) satu ,
      SUM(CASE WHEN f.`size` = 100 then f.quantity else 0 end) dua ,
      SUM(CASE WHEN f.`size` = 120 then f.quantity else 0 end) tiga ,
      SUM(CASE WHEN f.`size` = 140 then f.quantity else 0 end) empat ,
      SUM(CASE WHEN f.`size` = 160 then f.quantity else 0 end) lima ,
      SUM(CASE WHEN f.`size` = 180 then f.quantity else 0 end) enam ,
      SUM(CASE WHEN f.`size` = 200 then f.quantity else 0 end) tujuh ,
      SUM(f.quantity) total
    FROM  forecasts f WHERE `month` = 10 and `year` = 2022 and branch = 2 and brand is not null
    GROUP BY f.address_number , f.sales_name, f.brand , f.segment2_name, f.segment3, f.segment3_name").group_by(&:sales_name)
  end

  def self.nasional_aging_stock(brand)
    find_by_sql("
      SELECT branch_plan, branch_plan_desc, brand, grouping,  
  	    IFNULL(SUM(CASE WHEN cats = '1-2' THEN quantity END),0) AS 'satu',
  	    IFNULL(SUM(CASE WHEN cats = '2-4' THEN quantity END),0) AS 'dua',
	      IFNULL(SUM(CASE WHEN cats = '4-6' THEN quantity END),0) AS 'empat',
  	    IFNULL(SUM(CASE WHEN cats = '6-12' THEN quantity END),0) AS 'enam',
  	    IFNULL(SUM(CASE WHEN cats = '12-24' THEN quantity END),0) AS 'duabelas' ,
  	    IFNULL(SUM(CASE WHEN cats = '>730' THEN quantity END),0) AS 'duaempat'
      FROM aging_stock_details WHERE brand = '#{brand}' GROUP BY branch_plan, grouping ORDER BY branch_plan_desc ASC;
    ")
  end

  def self.cek_penjualan_pbjm_cabang(fdate, edate, kode, branch)
    a = find_by_sql("
	SELECT (CASE WHEN ri.harga_ri = 0 AND rm.harganetto2 > 0 THEN SUM(ri.jumlah) else SUM(ri.jumlah) END)  jumlah FROM
	(
	      SELECT kodebrg, nofaktur, SUM(jumlah) as jumlah, harganetto2 as harga_ri
	      FROM dbmarketing.tblaporancabang WHERE kodebrg = TRIM('#{kode}')
	      and ketppb = '#{branch}' and tanggalsj BETWEEN '#{fdate}' and '#{edate}' and
	      fiscal_year = '#{fdate.to_date.year}'
	      and tipecust = 'RETAIL' AND orty IN ('RI', 'RX') GROUP BY kodebrg, ketppb, nofaktur
	) AS ri
	LEFT JOIN
	(
	      SELECT kodebrg, reference, jumlah, harganetto2 FROM dbmarketing.tblaporancabang WHERE kodebrg = TRIM('#{kode}')
	      and ketppb = '#{branch}' AND tipecust = 'RETAIL' AND orty IN ('RM')
	) AS rm ON ri.kodebrg = rm.kodebrg AND ri.nofaktur = rm.reference
    ")
    b = a.first.nil? ? 0 : a.first.jumlah
    return b
  end

  def self.cek_stock_pbjm_cabang(date, kode, branch)
    a = find_by_sql("
      SELECT onhand FROM warehouse.F41021_STOCK WHERE item_number = TRIM('#{kode}') and branch = '#{branch}'
      and DATE(created_at) = '#{date}'
    ")
    b = a.empty? ? 0 : a.first.onhand
    return b
  end

  def self.calculate_customer_prog(area)
    find_by_sql("
      SELECT kode_customer as customer, customer as customer_desc, jenisbrgdisc as brand,
      SUM(CASE WHEN fiscal_month = #{12.months.ago.month} AND fiscal_year = #{12.months.ago.year} THEN harganetto2 ELSE 0 END) AS 'aa',
      SUM(CASE WHEN fiscal_month = #{11.months.ago.month} AND fiscal_year = #{11.months.ago.year} THEN harganetto2 ELSE 0 END) AS 'bb',
      SUM(CASE WHEN fiscal_month = #{10.months.ago.month} AND fiscal_year = #{10.months.ago.year} THEN harganetto2 ELSE 0 END) AS 'cc',
      SUM(CASE WHEN fiscal_month = #{9.months.ago.month} AND fiscal_year = #{9.months.ago.year} THEN harganetto2 ELSE 0 END) AS 'dd',
      SUM(CASE WHEN fiscal_month = #{8.months.ago.month} AND fiscal_year = #{8.months.ago.year} THEN harganetto2 ELSE 0 END) AS 'ee',
      SUM(CASE WHEN fiscal_month = #{7.months.ago.month} AND fiscal_year = #{7.months.ago.year} THEN harganetto2 ELSE 0 END) AS 'ff',
      SUM(CASE WHEN fiscal_month = #{6.months.ago.month} AND fiscal_year = #{6.months.ago.year} THEN harganetto2 ELSE 0 END) AS 'gg',
      SUM(CASE WHEN fiscal_month = #{5.months.ago.month} AND fiscal_year = #{5.months.ago.year} THEN harganetto2 ELSE 0 END) AS 'hh',
      SUM(CASE WHEN fiscal_month = #{4.months.ago.month} AND fiscal_year = #{4.months.ago.year} THEN harganetto2 ELSE 0 END) AS 'ii',
      SUM(CASE WHEN fiscal_month = #{3.months.ago.month} AND fiscal_year = #{3.months.ago.year} THEN harganetto2 ELSE 0 END) AS 'tigabulan',
      SUM(CASE WHEN fiscal_month = #{2.months.ago.month} AND fiscal_year = #{2.months.ago.year} THEN harganetto2 ELSE 0 END) AS 'kk',
      SUM(CASE WHEN fiscal_month = #{1.month.ago.month} AND fiscal_year = #{1.months.ago.year} THEN harganetto2 ELSE 0 END) AS 'll'
      FROM tblaporancabang WHERE area_id = #{area} AND fiscal_year BETWEEN #{12.months.ago.year} AND #{1.months.ago.year}
      GROUP BY kode_customer, jenisbrgdisc
    ")
  end

  def self.calculate_rkm_sales(week, year, address)
    date = Date.commercial(year.to_i, week.to_i).to_date
    find_by_sql("
      SELECT * FROM(
      SELECT cab.Cabang AS cabang, f1.address_number AS address_number, IFNULL(fw.sales_name, tl.salesman) AS sales_name, IFNULL(fw.week, tl.week) AS week,
      f1.item_number AS item_number, IFNULL(fw.size, tl.lebar) AS size, IFNULL(fw.brand, tl.jenisbrgdisc) AS brand,
      IFNULL(fw.segment2_name, tl.namaartikel) AS segment2_name, IFNULL(fw.segment3_name, tl.namakain) AS segment3_name,
      IFNULL(fw.quantity, 0) AS target_penjualan, IFNULL(tl.jumlah,0) AS jumlah_penjualan,
      IFNULL(st.onhand, 0) AS stock, f1.branch, (IFNULL(fw.quantity, 0)+IFNULL(rh.quantity,0)) AS total_target, rh.quantity AS sisa FROM
      (
        SELECT item_number, address_number, branch FROM forecast_weeklies WHERE
        WEEK = '#{week}' AND YEAR = '#{year}' AND address_number = '#{address}' GROUP BY item_number, branch, brand

        UNION

        SELECT DISTINCT(kodebrg), nopo, area_id FROM dbmarketing.tblaporancabang
        WHERE WEEK = '#{week}' AND fiscal_year = '#{year}' AND nopo = '#{address}' AND ketppb NOT LIKE '%D'
        AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO', 'RX')  GROUP BY area_id, kodebrg, jenisbrgdisc
      ) f1
      LEFT JOIN
      (
        SELECT * FROM forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{year}' GROUP BY branch, brand, address_number, item_number
      ) fw ON fw.branch = f1.branch AND fw.address_number = f1.address_number AND fw.item_number = f1.item_number
      LEFT JOIN
      (
        SELECT area_id, kodebrg, SUM(jumlah) AS jumlah, nopo, salesman, lebar, jenisbrgdisc, namaartikel, namakain, SUM(jumlah) AS jml, WEEK
        FROM dbmarketing.tblaporancabang
        WHERE WEEK = '#{week}' AND fiscal_year = '#{year}' AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO', 'RX')
        AND ketppb NOT LIKE '%D' GROUP BY area_id, kodebrg, nopo
      ) tl ON tl.area_id = f1.branch AND tl.kodebrg = f1.item_number AND tl.nopo = f1.address_number
      LEFT JOIN
      (
        SELECT item_number, address_number, WEEK, quantity, branch FROM rkm_histories WHERE week = '#{week.to_i-1}'
      ) rh ON rh.item_number = f1.item_number AND rh.address_number = f1.address_number and rh.branch = f1.branch
      LEFT JOIN
      (
        SELECT item_number, branch_code, SUM(onhand) AS onhand FROM warehouse.F41021_STOCK WHERE DATE(created_at) = '#{Date.today.beginning_of_week.to_date}'
        GROUP BY item_number, branch_code
      ) st ON st.item_number = f1.item_number AND st.branch_code = f1.branch
      LEFT JOIN
      (
        SELECT * FROM dbmarketing.tbidcabang
      ) cab ON cab.id = f1.branch
      ORDER BY IFNULL(fw.sales_name, tl.salesman) ASC, IFNULL(tl.jumlah,0) DESC
      ) au WHERE au.week is not null
    ")
  end

  def self.calculate_rkm_recap_admin(week, year, brand, area)
    date = Date.commercial(year.to_i, week.to_i).to_date
    find_by_sql("
      SELECT * FROM(
      SELECT cab.Cabang AS cabang, f1.address_number AS address_number, IFNULL(fw.sales_name, tl.salesman) AS sales_name,
      IFNULL(fw.brand, tl.jenisbrgdisc) AS brand,
      IFNULL(SUM(fw.quantity), 0) AS target_penjualan, IFNULL(SUM(tl.jumlah),0) AS jumlah_penjualan,
      f1.branch, (IFNULL(SUM(fw.quantity), 0)+IFNULL(SUM(rh.quantity),0)) AS total_target, rh.quantity AS sisa FROM
      (
        SELECT item_number, address_number, branch FROM forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{year}'
        AND (CASE WHEN '#{area}' = '' THEN branch >= 0 ELSE branch = '#{area}' END)
        GROUP BY address_number, item_number, branch

        UNION

        SELECT DISTINCT(kodebrg), nopo, area_id FROM dbmarketing.tblaporancabang
        WHERE WEEK = '#{week}' AND fiscal_year = '#{year}' AND nopo IS NOT NULL
        AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO', 'RX') AND
        (CASE WHEN '#{area}' = '' THEN area_id >= 0 ELSE area_id = '#{area}' END)
        GROUP BY area_id, kodebrg, nopo
      ) f1
      LEFT JOIN
      (
        SELECT * FROM forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{year}' AND
        (CASE WHEN '#{area}' = '' THEN branch >= 0 ELSE branch = '#{area}' END)
        GROUP BY branch, brand, address_number, item_number
      ) fw ON fw.branch = f1.branch AND fw.address_number = f1.address_number AND fw.item_number = f1.item_number
      LEFT JOIN
      (
        SELECT area_id, kodebrg, SUM(jumlah) AS jumlah, nopo, salesman, lebar, jenisbrgdisc, namaartikel, namakain, SUM(jumlah) AS jml, WEEK
        FROM dbmarketing.tblaporancabang
        WHERE WEEK = '#{week}' AND fiscal_year = '#{year}' AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO', 'RX')
        AND ketppb NOT LIKE '%D'
        GROUP BY area_id, kodebrg, nopo
      ) tl ON tl.area_id = f1.branch AND tl.kodebrg = f1.item_number AND tl.nopo = f1.address_number
      LEFT JOIN
      (
        SELECT item_number, address_number, WEEK, quantity, branch FROM rkm_histories WHERE week = '#{week.to_i-1}' and year = '#{year}'
      ) rh ON rh.item_number = f1.item_number AND rh.address_number = f1.address_number and rh.branch = f1.branch
      LEFT JOIN
      (
        SELECT * FROM dbmarketing.tbidcabang
      ) cab ON cab.id = f1.branch
      GROUP BY cab.Cabang, f1.address_number, IFNULL(fw.brand, tl.jenisbrgdisc)
      ORDER BY IFNULL(fw.brand, tl.jenisbrgdisc), IFNULL(fw.sales_name, tl.salesman) ASC, IFNULL(SUM(tl.jumlah),0) DESC
      ) au WHERE au.brand IS NOT null
    ")
  end

  def self.calculate_rkm_admin(week, year, brand)
    date = Date.commercial(year.to_i, week.to_i).to_date
    find_by_sql("
      SELECT * FROM(
      SELECT cab.Cabang AS cabang, f1.address_number AS address_number, IFNULL(fw.sales_name, tl.salesman) AS sales_name, IFNULL(fw.week, tl.week) AS week,
      f1.item_number AS item_number, IFNULL(fw.size, tl.lebar) AS size, IFNULL(fw.brand, tl.jenisbrgdisc) AS brand,
      IFNULL(fw.segment2_name, tl.namaartikel) AS segment2_name, IFNULL(fw.segment3_name, tl.namakain) AS segment3_name,
      IFNULL(fw.quantity, 0) AS target_penjualan, IFNULL(tl.jumlah,0) AS jumlah_penjualan, IFNULL(st.onhand, 0) AS stock,
      f1.branch, (IFNULL(fw.quantity, 0)+IFNULL(rh.quantity,0)) AS total_target, rh.quantity AS sisa FROM
      (
        SELECT item_number, address_number, branch, brand FROM forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{year}'
        AND brand = '#{brand}' GROUP BY address_number, item_number, branch

        UNION

        SELECT DISTINCT(kodebrg), nopo, area_id, jenisbrgdisc FROM dbmarketing.tblaporancabang
        WHERE WEEK = '#{week}' AND fiscal_year = '#{year}' AND nopo IS NOT NULL AND jenisbrgdisc = '#{brand}'
        AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO', 'RX') GROUP BY area_id, kodebrg, nopo
      ) f1
      LEFT JOIN
      (
        SELECT * FROM forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{year}' GROUP BY branch, brand, address_number, item_number
      ) fw ON fw.branch = f1.branch AND fw.address_number = f1.address_number AND fw.item_number = f1.item_number AND fw.brand = f1.brand
      LEFT JOIN
      (
        SELECT area_id, kodebrg, SUM(jumlah) AS jumlah, nopo, salesman, lebar, jenisbrgdisc, namaartikel, namakain, SUM(jumlah) AS jml, WEEK
        FROM dbmarketing.tblaporancabang
        WHERE WEEK = '#{week}' AND fiscal_year = '#{year}' AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO', 'RX')
        AND ketppb NOT LIKE '%D'
        GROUP BY area_id, kodebrg, nopo
      ) tl ON tl.area_id = f1.branch AND tl.kodebrg = f1.item_number AND tl.nopo = f1.address_number
      LEFT JOIN
      (
        SELECT item_number, address_number, WEEK, SUM(quantity) AS quantity, branch FROM rkm_histories WHERE week = '#{week.to_i-1}' and year = '#{year.to_i}'
      ) rh ON rh.item_number = f1.item_number AND rh.address_number = f1.address_number and rh.branch = f1.branch
      LEFT JOIN
      (
        SELECT item_number, branch_code, SUM(onhand) AS onhand FROM warehouse.F41021_STOCK WHERE DATE(created_at) = '#{Date.today.beginning_of_week.to_date}'
        GROUP BY item_number, branch_code
      ) st ON st.item_number = f1.item_number AND st.branch_code = f1.branch
      LEFT JOIN
      (
        SELECT * FROM dbmarketing.tbidcabang
      ) cab ON cab.id = f1.branch
      ORDER BY IFNULL(fw.sales_name, tl.salesman) ASC, IFNULL(tl.jumlah,0) DESC
      ) au WHERE au.week is not null
    ")
  end

  def self.calculate_rkm(week, year, area, brand)
    date = Date.commercial(year.to_i, week.to_i).to_date
    find_by_sql("
      SELECT * FROM(
      SELECT cab.Cabang AS cabang, f1.address_number AS address_number, IFNULL(fw.sales_name, tl.salesman) AS sales_name, IFNULL(fw.week, tl.week) AS week,
      f1.item_number AS item_number, IFNULL(fw.size, tl.lebar) AS size, IFNULL(fw.brand, tl.jenisbrgdisc) AS brand,
      IFNULL(fw.segment2_name, tl.namaartikel) AS segment2_name, IFNULL(fw.segment3_name, tl.namakain) AS segment3_name,
      IFNULL(fw.quantity, 0) AS target_penjualan, IFNULL(tl.jumlah,0) AS jumlah_penjualan,
      IFNULL(st.onhand, 0) AS stock, f1.branch, (IFNULL(fw.quantity, 0)+IFNULL(rh.quantity,0)) AS total_target, rh.quantity AS sisa FROM
      (
        SELECT item_number, address_number, branch FROM forecast_weeklies WHERE
        branch = '#{area}' AND WEEK = '#{week}' AND YEAR = '#{year}'
        AND brand = '#{brand}' GROUP BY address_number, item_number, branch

        UNION

        SELECT DISTINCT(kodebrg), nopo, area_id FROM dbmarketing.tblaporancabang
        WHERE WEEK = '#{week}' AND fiscal_year = '#{year}' AND area_id = '#{area}' AND nopo IS NOT NULL AND jenisbrgdisc = '#{brand}'
        AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO', 'RX') GROUP BY area_id, kodebrg, nopo
      ) f1
      LEFT JOIN
      (
        SELECT * FROM forecast_weeklies WHERE branch = '#{area}' AND WEEK = '#{week}' AND YEAR = '#{year}' GROUP BY branch, brand, address_number, item_number
      ) fw ON fw.branch = f1.branch AND fw.address_number = f1.address_number AND fw.item_number = f1.item_number
      LEFT JOIN
      (
        SELECT area_id, kodebrg, SUM(jumlah) AS jumlah, nopo, salesman, lebar, jenisbrgdisc, namaartikel, namakain, SUM(jumlah) AS jml, WEEK
        FROM dbmarketing.tblaporancabang
        WHERE WEEK = '#{week}' AND fiscal_year = '#{year}' AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO', 'RX')
        AND area_id = '#{area}' AND ketppb NOT LIKE '%D' GROUP BY area_id, kodebrg, nopo
      ) tl ON tl.area_id = f1.branch AND tl.kodebrg = f1.item_number AND tl.nopo = f1.address_number
      LEFT JOIN
      (
        SELECT item_number, address_number, WEEK, quantity, branch FROM rkm_histories WHERE week = '#{week.to_i-1}' and year = '#{year}'
      ) rh ON rh.item_number = f1.item_number AND rh.address_number = f1.address_number and rh.branch = f1.branch
      LEFT JOIN
      (
        SELECT item_number, branch_code, SUM(onhand) AS onhand FROM warehouse.F41021_STOCK WHERE DATE(created_at) = '#{Date.today.beginning_of_week.to_date}'
        GROUP BY item_number, branch_code
      ) st ON st.item_number = f1.item_number AND st.branch_code = f1.branch
      LEFT JOIN
      (
        SELECT * FROM dbmarketing.tbidcabang
      ) cab ON cab.id = f1.branch
      ORDER BY IFNULL(fw.sales_name, tl.salesman) ASC, IFNULL(tl.jumlah,0) DESC
      ) au WHERE au.week is not null
    ")
  end

  def self.calculation_forecast_year(start_date, end_date, area, brand)
    self.find_by_sql("
      SELECT f1.namaartikel, f.description, f.segment1, f.segment2_name, f.brand, f.month, f.year,
      lp.namabrg, a.area, f.branch, f.segment2_name, f.segment3_name,
      lp.kodejenis, lp.lebar, f.size, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv,
      lp.namaartikel, lp.namakain, f2.qty_last, lp2.jml_last, ((lp2.jml_last/f2.qty_last)*100) AS acv2
      FROM
      (
        SELECT DISTINCT(kodebrg), namaartikel, kodekain, namakain FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}'
        GROUP BY kodebrg

        UNION ALL

        SELECT DISTINCT(item_number), segment2_name, segment3, segment3_name FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND branch = '#{area}' AND brand = '#{brand}' GROUP BY item_number
      ) AS f1
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jumlah, kodebrg, namabrg, kodejenis, namaartikel, namakain, area_id, lebar,
        fiscal_month, fiscal_year, kodeartikel, kodekain FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}'
        GROUP BY kodebrg, area_id, jenisbrgdisc
      ) AS lp ON lp.kodebrg = f1.kodebrg
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jml_last, kodebrg, namabrg, kodejenis, namaartikel, namakain, area_id, lebar,
        fiscal_month, fiscal_year, kodeartikel, kodekain FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date.last_year}'
        AND '#{end_date.to_date.last_year}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}'
        GROUP BY kodebrg, area_id, jenisbrgdisc
      ) AS lp2 ON lp2.kodebrg = f1.kodebrg
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2, segment2_name,
        segment3_name, size, SUM(quantity) AS quantity, segment3 FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}' AND branch = '#{area}' GROUP BY item_number
      ) AS f ON f.item_number = f1.kodebrg
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2, segment2_name,
        segment3_name, size, SUM(quantity) AS qty_last, segment3 FROM
        forecasts WHERE month BETWEEN '#{start_date.to_date.last_year.month}' AND '#{end_date.to_date.last_year.month}'
        AND year BETWEEN '#{start_date.to_date.last_year.year}' AND '#{end_date.to_date.last_year.year}' AND branch = '#{area}' GROUP BY item_number
      ) AS f2 ON f2.item_number = f1.kodebrg
      LEFT JOIN
      (
        SELECT * FROM areas
      ) AS a ON IFNULL(lp.area_id, f.branch) = a.id
      WHERE lp.jumlah > 0 OR f.quantity > 0
      GROUP BY f1.kodebrg
    ")
  end

  def self.update_master_forecast
    self.all.each do |e|
      item = ItemMaster.where(item_number: e.item_number).first
      a = item.nil? ? 0 : item.segment1
      e.update_attributes!(segment1: a)
    end
  end

  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      forecast = find_by(brand: row["brand"], address_number: row["address_number"].to_i, item_number: row["item_number"].strip, branch: row["branch"],
      month: row["month"], year: row["year"], week: row["week"]) || new
      unless row["quantity"].nil? || row["quantity"] == 0
        if forecast.id.nil?
          item = JdeItemMaster.get_desc_forecast(row["item_number"])
          sales_name = Jde.get_sales_rkb(row["address_number"].to_i)
          row["segment1"] = item.nil? ? 0 : item.imseg1.strip
          row["segment2"] = item.nil? ? 0 : item.imseg2.strip
          row["segment3"] = item.nil? ? 0 : item.imseg3.strip
          row["segment2_name"] = item.nil? ? 0 : JdeUdc.artikel_udc(item.imseg2.strip)
          row["segment3_name"] = item.nil? ? 0 : JdeUdc.kain_udc(item.imseg3.strip)
          row["size"] = item.nil? ? 0 : item.imseg6.strip
          row["description"] = item.nil? ? 'UNLISTED ITEM NUMBER' : (item.imdsc1.strip + ' ' + item.imdsc2.strip)
          row["planner"] = '-'
          row["sales_name"] = sales_name.nil? ? ' ' : sales_name.abalph.strip
        forecast.attributes = row.to_hash
        else
          forecast["quantity"] = row["quantity"]
        end
      forecast.save!
      end
    end
  end

  def self.calculation_forecasts_by_branch(start_date, end_date, area)
    self.find_by_sql("
      SELECT oa.jenisbrgdisc AS brand, SUM(oa.quantity) AS quantity, SUM(oa.jumlah) AS jumlah,
      SUM(oa.acv) AS acv, SUM(oa.todate) AS todate, SUM(IFNULL(equal_sales,0)) AS equal_sales,
      SUM(IFNULL(more_sales,0)) AS more_sales, SUM(IFNULL(less_sales,0)) AS less_sales,
      SUM(IFNULL(more_sales_for_non,0)) AS msfn FROM
      (
            SELECT lp.kodebrg, f.todate, IFNULL(lp.jenisbrgdisc, f.brand) AS jenisbrgdisc, lp.namabrg, a.area,
            f.branch, f.size, f.quantity, lp.jumlah, ABS((IFNULL(lp.jumlah,0)-IFNULL(f.todate,0))) AS acv,
            CASE WHEN IFNULL(lp.jumlah,0) = IFNULL(f.todate, 0) THEN lp.jumlah END AS equal_sales,
            CASE WHEN IFNULL(lp.jumlah,0) > IFNULL(f.todate,0) THEN f.todate END AS more_sales,
            CASE WHEN IFNULL(lp.jumlah,0) < IFNULL(f.todate,0) THEN lp.jumlah END AS less_sales,
            CASE WHEN IFNULL(lp.jumlah,0) > IFNULL(f.todate,0) THEN
            (IFNULL(lp.jumlah,0) - IFNULL(f.todate,0)) END AS more_sales_for_non
            FROM
            (
              SELECT DISTINCT(kodebrg) FROM
              tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
              ('KM', 'DV', 'HB', 'KB', 'SB', 'SA', 'ST')  AND tanggalsj BETWEEN '#{start_date.to_date}'
              AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc NOT LIKE 'CLASSIC'

              UNION ALL

              SELECT DISTINCT(item_number) FROM
              forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
              '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}'
              AND '#{end_date.to_date.year}' AND branch = '#{area}'
            ) AS f1
            LEFT JOIN
            (
              SELECT SUM(jumlah) AS jumlah, jenisbrgdisc, kodebrg, namabrg, area_id, fiscal_month, fiscal_year FROM
              tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
              ('KM', 'DV', 'HB', 'KB', 'SB', 'SA', 'ST')  AND tanggalsj
              BETWEEN '#{start_date.to_date}' AND '#{end_date.to_date}' AND area_id = '#{area}'
              AND jenisbrgdisc NOT LIKE 'CLASSIC'
              GROUP BY area_id, kodebrg
            ) AS lp ON lp.kodebrg = f1.kodebrg
            LEFT JOIN
            (
              SELECT brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
              segment3_name, size, SUM(quantity) AS quantity,
              ROUND((SUM(quantity)/DAY(LAST_DAY('#{end_date.to_date}')))*DAY('#{end_date.to_date}')) AS todate FROM
              forecasts WHERE branch = '#{area}' AND MONTH BETWEEN '#{start_date.to_date.month}' AND
              '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
              GROUP BY item_number
            ) AS f ON f.item_number = f1.kodebrg
            LEFT JOIN
            (
              SELECT * FROM areas
            ) AS a ON f.branch = a.id
      GROUP BY f1.kodebrg
      ) AS oa GROUP BY oa.jenisbrgdisc
    ")
  end

  def self.calculation_forecasts_salesman(start_date, end_date, area, brand)
    self.find_by_sql("
      SELECT f1.kodebrg, f.description, f.segment1, f.segment2_name, f.brand, f.month, f.year,
      lp.namabrg, a.area, f.branch, f.segment2_name, f.segment3_name, f.sales_name, f.address_number,
      lp.kodejenis, lp.lebar, f.size, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv, lp.namaartikel, lp.namakain,
      IFNULL(s.onhand, 0) AS onhand,
      IFNULL(ib.qty_buf, 0) AS qty_buf FROM
      (
        SELECT DISTINCT(kodebrg), nopo FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}' AND orty IN ('RI', 'RO', 'RX')

        UNION ALL

        SELECT DISTINCT(item_number), address_number FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND branch = '#{area}' AND brand = '#{brand}'
      ) AS f1
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jumlah, kodebrg, namabrg, kodejenis, namaartikel, namakain, area_id, lebar,
        fiscal_month, fiscal_year, nopo, salesman FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}' AND orty IN ('RI', 'RO', 'RX')
        GROUP BY kodebrg, area_id, jenisbrgdisc, nopo
      ) AS lp ON lp.kodebrg = f1.kodebrg AND lp.nopo = f1.nopo
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
        segment3_name, size, SUM(quantity) AS quantity, address_number, sales_name FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND branch = '#{area}' GROUP BY item_number, address_number
      ) AS f ON f.item_number = f1.kodebrg AND f.branch = '#{area}' AND f.address_number = f1.nopo
      LEFT JOIN
      (
        SELECT onhand, item_number, area_id, short_item FROM stocks WHERE status = 'N'
      ) AS s ON s.item_number = f1.kodebrg AND s.area_id = #{area}
      LEFT JOIN
      (
        SELECT quantity AS qty_buf, short_item, area FROM item_branches
      ) AS ib ON s.short_item = ib.short_item AND s.area_id = ib.area
      LEFT JOIN
      (
        SELECT * FROM areas
      ) AS a ON IFNULL(lp.area_id, f.branch) = a.id
      GROUP BY f1.kodebrg, f1.nopo
    ")
  end

  def self.calculation_forecasts(start_date, end_date, area, brand)
    self.find_by_sql("
      SELECT f1.kodebrg, f.description, f.segment1, f.segment2_name, f.brand, f.month, f.year,
      lp.namabrg, a.area, f.branch, f.segment2_name, f.segment3_name,
      lp.kodejenis, lp.lebar, f.size, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv, lp.namaartikel, lp.namakain,
      IFNULL(s.onhand, 0) AS onhand,
      IFNULL(ib.qty_buf, 0) AS qty_buf FROM
      (
        SELECT DISTINCT(kodebrg) FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}' AND orty IN ('RI', 'RO', 'RX')

        UNION ALL

        SELECT DISTINCT(item_number) FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND branch = '#{area}' AND brand = '#{brand}'
      ) AS f1
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jumlah, kodebrg, namabrg, kodejenis, namaartikel, namakain, area_id, lebar,
        fiscal_month, fiscal_year FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}' AND orty IN ('RI', 'RO', 'RX')
        GROUP BY kodebrg, area_id, jenisbrgdisc
      ) AS lp ON lp.kodebrg = f1.kodebrg
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
        segment3_name, size, SUM(quantity) AS quantity FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND branch = '#{area}' GROUP BY item_number
      ) AS f ON f.item_number = f1.kodebrg AND f.branch = '#{area}'
      LEFT JOIN
      (
        SELECT onhand, item_number, area_id, short_item FROM stocks WHERE status = 'N'
      ) AS s ON s.item_number = f1.kodebrg AND s.area_id = #{area}
      LEFT JOIN
      (
        SELECT quantity AS qty_buf, short_item, area FROM item_branches
      ) AS ib ON s.short_item = ib.short_item AND s.area_id = ib.area
      LEFT JOIN
      (
        SELECT * FROM areas
      ) AS a ON IFNULL(lp.area_id, f.branch) = a.id
      GROUP BY f1.kodebrg
    ")
  end

  def self.calculation_direct_forecast(start_date, end_date, area)
    id_img = area == 100 ? "DIRECT" : "MODERN"
    self.find_by_sql("
      SELECT f1.kodebrg, f.description, f.segment1, f.segment2_name, f.brand, f.month, f.year,
      lp.namabrg, f.branch, f.segment2_name, f.segment3_name,
      lp.kodejenis, lp.lebar, f.size, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv,
      lp.namaartikel, lp.namakain FROM
      (
        SELECT DISTINCT(kodebrg) FROM
        tblaporancabang WHERE tipecust = '#{id_img}' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}'

        UNION ALL

        SELECT DISTINCT(item_number) FROM
        forecasts WHERE MONTH = '#{end_date.to_date.month}' AND YEAR = '#{end_date.to_date.year}'
        AND branch = '#{area}'
      ) AS f1
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jumlah, kodebrg, namabrg, kodejenis, namaartikel, namakain, area_id, lebar,
        fiscal_month, fiscal_year FROM
        tblaporancabang WHERE tipecust = '#{id_img}' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}'
        GROUP BY kodebrg, jenisbrgdisc, fiscal_month, fiscal_year
      ) AS lp ON lp.kodebrg = f1.kodebrg
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
        segment3_name, size, SUM(quantity) AS quantity FROM
        forecasts WHERE month = '#{start_date.to_date.month}'
        AND year = '#{start_date.to_date.year}' AND branch = '#{area}' GROUP BY item_number
      ) AS f ON f.item_number = f1.kodebrg
      GROUP BY f1.kodebrg
    ")
  end

  def self.calculate_rkb_report(from, to , branch)
    find_by_sql("
      SELECT sales_name, customer,SUM(plan1) AS plan1,SUM(actual1) AS actual1
      ,SUM(plan2) AS plan2,SUM(actual2) AS actual2
      ,SUM(plan3) AS plan3,SUM(actual3) AS actual3
      ,SUM(plan4) AS plan4,SUM(actual4) AS actual4
      ,SUM(plan5) AS plan5,SUM(actual5) AS actual5
      ,SUM(plan6) AS plan6,SUM(actual6) AS actual6
      ,SUM(plan7) AS plan7,SUM(actual7) AS actual7
      ,SUM(plan8) AS plan8,SUM(actual8) AS actual8
      ,SUM(plan9) AS plan9,SUM(actual9) AS actual9
      ,SUM(plan10) AS plan10,SUM(actual10) AS actual10
      ,SUM(plan11) AS plan11,SUM(actual11) AS actual11
      ,SUM(plan12) AS plan12,SUM(actual12) AS actual12
      ,SUM(plan13) AS plan13,SUM(actual13) AS actual13
      ,SUM(plan14) AS plan14,SUM(actual14) AS actual14
      ,SUM(plan15) AS plan15,SUM(actual15) AS actual15
      ,SUM(plan16) AS plan16,SUM(actual16) AS actual16
      ,SUM(plan17) AS plan17,SUM(actual17) AS actual17
      ,SUM(plan18) AS plan18,SUM(actual18) AS actual18
      ,SUM(plan19) AS plan19,SUM(actual19) AS actual19
      ,SUM(plan20) AS plan20,SUM(actual20) AS actual20
      ,SUM(plan21) AS plan21,SUM(actual21) AS actual21
      ,SUM(plan22) AS plan22,SUM(actual22) AS actual22
      ,SUM(plan23) AS plan23,SUM(actual23) AS actual23
      ,SUM(plan24) AS plan24,SUM(actual24) AS actual24
      ,SUM(plan25) AS plan25,SUM(actual25) AS actual25
      ,SUM(plan26) AS plan26,SUM(actual26) AS actual26
      ,SUM(plan27) AS plan27,SUM(actual27) AS actual27
      ,SUM(plan28) AS plan28,SUM(actual28) AS actual28
      ,SUM(plan29) AS plan29,SUM(actual29) AS actual29
      ,SUM(plan30) AS plan30,SUM(actual30) AS actual30
      ,SUM(plan31) AS plan31,SUM(actual31) AS actual31
       FROM
       (SELECT b.sales_name, b.customer, b.date AS tglplan, '' AS tglactual
      ,CASE WHEN DAY(b.date)='1' THEN '1' ELSE '0' END AS plan1, '0' AS actual1
      ,CASE WHEN DAY(b.date)='2' THEN '1' ELSE '0' END AS plan2, '0' AS actual2
      ,CASE WHEN DAY(b.date)='3' THEN '1' ELSE '0' END AS plan3, '0' AS actual3
      ,CASE WHEN DAY(b.date)='4' THEN '1' ELSE '0' END AS plan4, '0' AS actual4
      ,CASE WHEN DAY(b.date)='5' THEN '1' ELSE '0' END AS plan5, '0' AS actual5
      ,CASE WHEN DAY(b.date)='6' THEN '1' ELSE '0' END AS plan6, '0' AS actual6
      ,CASE WHEN DAY(b.date)='7' THEN '1' ELSE '0' END AS plan7, '0' AS actual7
      ,CASE WHEN DAY(b.date)='8' THEN '1' ELSE '0' END AS plan8, '0' AS actual8
      ,CASE WHEN DAY(b.date)='9' THEN '1' ELSE '0' END AS plan9, '0' AS actual9
      ,CASE WHEN DAY(b.date)='10' THEN '1' ELSE '0' END AS plan10, '0' AS actual10
      ,CASE WHEN DAY(b.date)='11' THEN '1' ELSE '0' END AS plan11, '0' AS actual11
      ,CASE WHEN DAY(b.date)='12' THEN '1' ELSE '0' END AS plan12, '0' AS actual12
      ,CASE WHEN DAY(b.date)='13' THEN '1' ELSE '0' END AS plan13, '0' AS actual13
      ,CASE WHEN DAY(b.date)='14' THEN '1' ELSE '0' END AS plan14, '0' AS actual14
      ,CASE WHEN DAY(b.date)='15' THEN '1' ELSE '0' END AS plan15, '0' AS actual15
      ,CASE WHEN DAY(b.date)='16' THEN '1' ELSE '0' END AS plan16, '0' AS actual16
      ,CASE WHEN DAY(b.date)='17' THEN '1' ELSE '0' END AS plan17, '0' AS actual17
      ,CASE WHEN DAY(b.date)='18' THEN '1' ELSE '0' END AS plan18, '0' AS actual18
      ,CASE WHEN DAY(b.date)='19' THEN '1' ELSE '0' END AS plan19, '0' AS actual19
      ,CASE WHEN DAY(b.date)='20' THEN '1' ELSE '0' END AS plan20, '0' AS actual20
      ,CASE WHEN DAY(b.date)='21' THEN '1' ELSE '0' END AS plan21, '0' AS actual21
      ,CASE WHEN DAY(b.date)='22' THEN '1' ELSE '0' END AS plan22, '0' AS actual22
      ,CASE WHEN DAY(b.date)='23' THEN '1' ELSE '0' END AS plan23, '0' AS actual23
      ,CASE WHEN DAY(b.date)='24' THEN '1' ELSE '0' END AS plan24, '0' AS actual24
      ,CASE WHEN DAY(b.date)='25' THEN '1' ELSE '0' END AS plan25, '0' AS actual25
      ,CASE WHEN DAY(b.date)='26' THEN '1' ELSE '0' END AS plan26, '0' AS actual26
      ,CASE WHEN DAY(b.date)='27' THEN '1' ELSE '0' END AS plan27, '0' AS actual27
      ,CASE WHEN DAY(b.date)='28' THEN '1' ELSE '0' END AS plan28, '0' AS actual28
      ,CASE WHEN DAY(b.date)='29' THEN '1' ELSE '0' END AS plan29, '0' AS actual29
      ,CASE WHEN DAY(b.date)='30' THEN '1' ELSE '0' END AS plan30, '0' AS actual30
      ,CASE WHEN DAY(b.date)='31' THEN '1' ELSE '0' END AS plan31, '0' AS actual31
       FROM salesmen a
      LEFT JOIN monthly_visit_plans b ON a.nik=b.address_number
      WHERE MONTH(b.DATE)= #{from.to_date.month} AND YEAR(b.DATE)= #{from.to_date.year} AND b.branch = #{branch}
      UNION ALL
      SELECT c.nama AS sales_name, customer, '' AS tglplan, b.DATE AS tglactual
      ,'0' AS plan1,CASE WHEN DAY(b.date)='1' THEN '1' ELSE '0' END AS actual1
      ,'0' AS plan2, CASE WHEN DAY(b.date)='2' THEN '1' ELSE '0' END AS actual2
      ,'0' AS plan3, CASE WHEN DAY(b.date)='3' THEN '1' ELSE '0' END AS actual3
      ,'0' AS plan4, CASE WHEN DAY(b.date)='4' THEN '1' ELSE '0' END AS actual4
      ,'0' AS plan5, CASE WHEN DAY(b.date)='5' THEN '1' ELSE '0' END AS actual5
      ,'0' AS plan6, CASE WHEN DAY(b.date)='6' THEN '1' ELSE '0' END AS actual6
      ,'0' AS plan7, CASE WHEN DAY(b.date)='7' THEN '1' ELSE '0' END AS actual7
      ,'0' AS plan8, CASE WHEN DAY(b.date)='8' THEN '1' ELSE '0' END AS actual8
      ,'0' AS plan9, CASE WHEN DAY(b.date)='9' THEN '1' ELSE '0' END AS actual9
      ,'0' AS plan10, CASE WHEN DAY(b.date)='10' THEN '1' ELSE '0' END AS actual10
      ,'0' AS plan11, CASE WHEN DAY(b.date)='11' THEN '1' ELSE '0' END AS actual11
      ,'0' AS plan12, CASE WHEN DAY(b.date)='12' THEN '1' ELSE '0' END AS actual12
      ,'0' AS plan13, CASE WHEN DAY(b.date)='13' THEN '1' ELSE '0' END AS actual13
      ,'0' AS plan14, CASE WHEN DAY(b.date)='14' THEN '1' ELSE '0' END AS actual14
      ,'0' AS plan15, CASE WHEN DAY(b.date)='15' THEN '1' ELSE '0' END AS actual15
      ,'0' AS plan16, CASE WHEN DAY(b.date)='16' THEN '1' ELSE '0' END AS actual16
      ,'0' AS plan17, CASE WHEN DAY(b.date)='17' THEN '1' ELSE '0' END AS actual17
      ,'0' AS plan18, CASE WHEN DAY(b.date)='18' THEN '1' ELSE '0' END AS actual18
      ,'0' AS plan19, CASE WHEN DAY(b.date)='19' THEN '1' ELSE '0' END AS actual19
      ,'0' AS plan20, CASE WHEN DAY(b.date)='20' THEN '1' ELSE '0' END AS actual20
      ,'0' AS plan21, CASE WHEN DAY(b.date)='21' THEN '1' ELSE '0' END AS actual21
      ,'0' AS plan22, CASE WHEN DAY(b.date)='22' THEN '1' ELSE '0' END AS actual22
      ,'0' AS plan23, CASE WHEN DAY(b.date)='23' THEN '1' ELSE '0' END AS actual23
      ,'0' AS plan24, CASE WHEN DAY(b.date)='24' THEN '1' ELSE '0' END AS actual24
      ,'0' AS plan25, CASE WHEN DAY(b.date)='25' THEN '1' ELSE '0' END AS actual25
      ,'0' AS plan26, CASE WHEN DAY(b.date)='26' THEN '1' ELSE '0' END AS actual26
      ,'0' AS plan27, CASE WHEN DAY(b.date)='27' THEN '1' ELSE '0' END AS actual27
      ,'0' AS plan28, CASE WHEN DAY(b.date)='28' THEN '1' ELSE '0' END AS actual28
      ,'0' AS plan29, CASE WHEN DAY(b.date)='29' THEN '1' ELSE '0' END AS actual29
      ,'0' AS plan30, CASE WHEN DAY(b.date)='30' THEN '1' ELSE '0' END AS actual30
      ,'0' AS plan31, CASE WHEN DAY(b.date)='31' THEN '1' ELSE '0' END AS actual31
       FROM sales_productivity_customers a INNER JOIN sales_productivities b ON a.sales_productivity_id=b.id INNER JOIN salesmen c ON b.salesmen_id=c.id
      WHERE a.call_visit='visit' AND MONTH(b.date)= #{from.to_date.month} AND YEAR(b.date)=#{from.to_date.year} AND b.branch_id = #{branch}) X
      GROUP BY sales_name, customer
    ")
  end

end
