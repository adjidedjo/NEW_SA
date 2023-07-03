class Forecast < ActiveRecord::Base

  def self.calculation_forecasts(start_date, end_date, area)
    self.find_by_sql("
      SELECT f1.kodebrg, f.description, IFNULL(f.segment1,lp.segment1_code) AS segment1_code, f.segment2_name, f.month, f.year,
      IFNULL(lp.product_name, f.description) as product_name, a.description, f.branch, f.segment2_name, f.segment3_name,
      lp.lebar, f.size, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv, lp.segment2_code, lp.segment3_code,
      IFNULL(s.onhand, 0) AS onhand, IFNULL(lp.brand, f.brand) as brand,
      IFNULL(ib.qty_buf, 0) AS qty_buf, IFNULL(lp.customer_type, f.channel) as channel FROM
      (
        SELECT DISTINCT(item_number) as kodebrg FROM
          sales_mart.DETAIL_SALES_FOR_FORECASTS  WHERE bp = '#{area}' AND MONTH BETWEEN '#{start_date.to_date.month}' AND
          '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}' 

        UNION ALL

        SELECT DISTINCT(item_number) FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND gudang_id = '#{area}'
      ) AS f1
      LEFT JOIN
      (
        SELECT SUM(total) AS jumlah, item_number, product_name, area_id, panjang, lebar,
        month, year, nopo, salesman, bom_name, segment1_code, segment2_code, segment3_code, brand, bp, customer_type FROM
        sales_mart.DETAIL_SALES_FOR_FORECASTS  WHERE invoice_date BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND bp != 0 AND bp = '#{area}'
        GROUP BY item_number, nopo, area_id, brand
      ) AS lp ON lp.item_number = f1.kodebrg
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
        segment3_name, size, SUM(quantity) AS quantity, gudang_id, channel FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND gudang_id = '#{area}' GROUP BY item_number, brand
      ) AS f ON f.item_number = f1.kodebrg AND f.gudang_id = '#{area}'
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
        SELECT * FROM gudangs
      ) AS a ON IFNULL(lp.bp, f.gudang_id) = a.code
      GROUP BY f1.kodebrg
    ")
  end

  def self.calculation_forecasts_by_manage_bom(start_date, end_date, channel)
    self.find_by_sql("
      SELECT report.address_number, report.sales_name, report.brand, SUM(report.forecast) as total_forecast, 	  
        ROUND((SUM(report.forecast)/DAY(LAST_DAY('#{end_date}')))*DAY('#{end_date}')) AS todate ,
        SUM(report.sales) as total_sales, report.branch,
        SUM(report.realisasi_forecast) as total_realisasi_forecast, report.bom, report.bom_name FROM
        (
        SELECT IFNULL(f.sales_name, lp.salesman) as sales_name, 
              IFNULL(f.address_number, lp.nopo) as address_number, f1.item_number, f1.brand,
              IFNULL(f.quantity,0) AS forecast, IFNULL(lp.area_id, branch) as branch,
              IFNULL(lp.jumlah,0) as sales, 
              CASE 
                WHEN (lp.jumlah < 0) and (IFNULL(f.quantity, 0) = 0) THEN 0
                WHEN IFNULL(lp.jumlah,0) > IFNULL(f.quantity,0) THEN IFNULL(f.quantity,0) 
              ELSE 
                IFNULL(lp.jumlah,0) 
              END AS realisasi_forecast, 
              ((lp.jumlah/f.quantity)*100) AS acv, lp.bom_name, lp.bom
              FROM
              (
                SELECT DISTINCT(item_number), brand as brand, nopo FROM
                sales_mart.DETAIL_SALES_FOR_FORECASTS WHERE invoice_date BETWEEN '#{start_date.to_date}'
                AND '#{end_date.to_date}' AND bp != 0 and customer_type like '#{channel}%'

                UNION

                SELECT DISTINCT(item_number), brand, address_number FROM
                forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}'
                AND '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}'
                AND '#{end_date.to_date.year}' and channel = '#{channel}' 
              ) AS f1
              LEFT JOIN
              (
                SELECT SUM(total) AS jumlah, item_number, product_name, area_id, panjang, lebar,
                month, year, nopo, salesman, bom, bom_name FROM
                sales_mart.DETAIL_SALES_FOR_FORECASTS  WHERE invoice_date BETWEEN '#{start_date.to_date}'
                AND '#{end_date.to_date}' AND bp != 0 and customer_type like '#{channel}%'
                GROUP BY item_number, nopo, area_id, brand
              ) AS lp ON lp.item_number = f1.item_number AND (lp.nopo = f1.nopo)
              LEFT JOIN
              (
                SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
                segment3_name, size, SUM(quantity) AS quantity, address_number, sales_name FROM
                forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}'
                AND '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}'
                AND '#{end_date.to_date.year}' and channel = '#{channel}' GROUP BY item_number, address_number
              ) AS f ON f.item_number = f1.item_number AND f.address_number = f1.nopo
              LEFT JOIN
              (
                SELECT * FROM areas
              ) AS a ON IFNULL(lp.area_id, f.branch) = a.id
              GROUP BY f1.item_number, f1.nopo
        ) report
      GROUP BY report.bom, report.brand
    ")
  end

  def self.calculation_forecasts_by_manage_sales(start_date, end_date)
    self.find_by_sql("
      SELECT report.address_number, report.sales_name, report.brand, SUM(report.forecast) as total_forecast, 	  
        ROUND((SUM(report.forecast)/DAY(LAST_DAY('#{end_date}')))*DAY('#{end_date}')) AS todate ,
        SUM(report.sales) as total_sales, report.branch,
        SUM(report.realisasi_forecast) as total_realisasi_forecast, report.bom_name FROM
        (
        SELECT IFNULL(f.sales_name, lp.salesman) as sales_name, 
              IFNULL(f.address_number, lp.nopo) as address_number, f1.item_number, f1.brand,
              IFNULL(f.quantity,0) AS forecast, IFNULL(lp.area_id, branch) as branch,
              IFNULL(lp.jumlah,0) as sales, 
              CASE 
                WHEN (lp.jumlah < 0) and (IFNULL(f.quantity, 0) = 0) THEN 0
                WHEN IFNULL(lp.jumlah,0) > IFNULL(f.quantity,0) THEN IFNULL(f.quantity,0) 
              ELSE 
                IFNULL(lp.jumlah,0) 
              END AS realisasi_forecast, 
              ((lp.jumlah/f.quantity)*100) AS acv, lp.bom_name
              FROM
              (
                SELECT DISTINCT(item_number), brand as brand, nopo FROM
                sales_mart.DETAIL_SALES_FOR_FORECASTS WHERE invoice_date BETWEEN '#{start_date.to_date}'
                AND '#{end_date.to_date}' AND bp != 0

                UNION

                SELECT DISTINCT(item_number), brand, address_number FROM
                forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}'
                AND '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}'
                AND '#{end_date.to_date.year}'
              ) AS f1
              LEFT JOIN
              (
                SELECT SUM(total) AS jumlah, item_number, product_name, area_id, panjang, lebar,
                month, year, nopo, salesman, bom_name FROM
                sales_mart.DETAIL_SALES_FOR_FORECASTS  WHERE invoice_date BETWEEN '#{start_date.to_date}'
                AND '#{end_date.to_date}' AND bp != 0
                GROUP BY item_number, nopo, area_id, brand
              ) AS lp ON lp.item_number = f1.item_number AND (lp.nopo = f1.nopo)
              LEFT JOIN
              (
                SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
                segment3_name, size, SUM(quantity) AS quantity, address_number, sales_name FROM
                forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}'
                AND '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}'
                AND '#{end_date.to_date.year}' GROUP BY item_number, address_number
              ) AS f ON f.item_number = f1.item_number AND f.address_number = f1.nopo
              LEFT JOIN
              (
                SELECT * FROM areas
              ) AS a ON IFNULL(lp.area_id, f.branch) = a.id
              GROUP BY f1.item_number, f1.nopo
        ) report
      GROUP BY report.address_number, report.brand
    ")
  end

  def self.calculation_forecasts_by_manage_branch(start_date, end_date, channel)
    self.find_by_sql("
      SELECT report.address_number, report.sales_name, report.brand, SUM(report.forecast) as total_forecast, 	  
        ROUND((SUM(report.forecast)/DAY(LAST_DAY('#{end_date}')))*DAY('#{end_date}')) AS todate ,
        SUM(report.sales) as total_sales, report.branch,
        SUM(report.realisasi_forecast) as total_realisasi_forecast FROM
        (
        SELECT IFNULL(f.sales_name, lp.salesman) as sales_name, 
              IFNULL(f.address_number, lp.nopo) as address_number, f1.item_number, f1.brand,
              IFNULL(f.quantity,0) AS forecast, IFNULL(lp.area_id, branch) as branch,
              IFNULL(lp.jumlah,0) as sales, 
              CASE 
                WHEN (lp.jumlah < 0) and (IFNULL(f.quantity, 0) = 0) THEN 0
                WHEN IFNULL(lp.jumlah,0) > IFNULL(f.quantity,0) THEN IFNULL(f.quantity,0) 
              ELSE 
                IFNULL(lp.jumlah,0) 
              END AS realisasi_forecast, 
              ((lp.jumlah/f.quantity)*100) AS acv
              FROM
              (
                SELECT DISTINCT(item_number), brand as brand, nopo FROM
                sales_mart.DETAIL_SALES_FOR_FORECASTS WHERE invoice_date BETWEEN '#{start_date.to_date}'
                AND '#{end_date.to_date}' AND bp != 0 and customer_type like '#{channel}%'

                UNION

                SELECT DISTINCT(item_number), brand, address_number FROM
                forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}'
                AND '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}'
                AND '#{end_date.to_date.year}' and channel = '#{channel}'
              ) AS f1
              LEFT JOIN
              (
                SELECT SUM(total) AS jumlah, item_number, product_name, area_id, panjang, lebar,
                month, year, nopo, salesman FROM
                sales_mart.DETAIL_SALES_FOR_FORECASTS  WHERE invoice_date BETWEEN '#{start_date.to_date}'
                AND '#{end_date.to_date}' AND bp != 0 and customer_type like '#{channel}%'
                GROUP BY item_number, nopo, area_id, brand
              ) AS lp ON lp.item_number = f1.item_number AND (lp.nopo = f1.nopo)
              LEFT JOIN
              (
                SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
                segment3_name, size, SUM(quantity) AS quantity, address_number, sales_name FROM
                forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}'
                AND '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}'
                AND '#{end_date.to_date.year}' and channel = '#{channel}' GROUP BY item_number, address_number
              ) AS f ON f.item_number = f1.item_number AND f.address_number = f1.nopo
              GROUP BY f1.item_number, f1.nopo
        ) report
      GROUP BY report.branch, report.brand
    ")
  end

  def self.calculation_forecasts_by_brand(start_date, end_date, channel)
    self.find_by_sql("
      SELECT report.address_number, report.sales_name, report.brand, SUM(report.forecast) as total_forecast, 	  
        ROUND((SUM(report.forecast)/DAY(LAST_DAY('#{end_date}')))*DAY('#{end_date}')) AS todate ,
        SUM(report.sales) as total_sales,
        SUM(report.realisasi_forecast) as total_realisasi_forecast FROM
        (
        SELECT IFNULL(f.sales_name, lp.salesman) as sales_name, 
              IFNULL(f.address_number, lp.nopo) as address_number, f1.item_number, f1.brand,
              IFNULL(f.quantity,0) AS forecast, 
              IFNULL(lp.jumlah,0) as sales, 
              CASE 
                WHEN (lp.jumlah < 0) and (IFNULL(f.quantity, 0) = 0) THEN 0
                WHEN IFNULL(lp.jumlah,0) > IFNULL(f.quantity,0) THEN IFNULL(f.quantity,0) 
              ELSE 
                IFNULL(lp.jumlah,0) 
              END AS realisasi_forecast, 
              ((lp.jumlah/f.quantity)*100) AS acv
              FROM
              (
                SELECT DISTINCT(item_number), brand as brand, nopo FROM
                sales_mart.DETAIL_SALES_FOR_FORECASTS WHERE invoice_date BETWEEN '#{start_date.to_date}'
                AND '#{end_date.to_date}' AND bp != 0 and customer_type like '#{channel}%'

                UNION

                SELECT DISTINCT(item_number), brand, address_number FROM
                forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}'
                AND '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}'
                AND '#{end_date.to_date.year}' and channel = '#{channel}'
              ) AS f1
              LEFT JOIN
              (
                SELECT SUM(total) AS jumlah, item_number, product_name, area_id, panjang, lebar,
                month, year, nopo, salesman FROM
                sales_mart.DETAIL_SALES_FOR_FORECASTS  WHERE invoice_date BETWEEN '#{start_date.to_date}'
                AND '#{end_date.to_date}' AND bp != 0 and customer_type like '#{channel}%'
                GROUP BY item_number, nopo, area_id, brand
              ) AS lp ON lp.item_number = f1.item_number AND (lp.nopo = f1.nopo)
              LEFT JOIN
              (
                SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
                segment3_name, size, SUM(quantity) AS quantity, address_number, sales_name FROM
                forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}'
                AND '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}'
                AND '#{end_date.to_date.year}' and channel = '#{channel}' GROUP BY item_number, address_number
              ) AS f ON f.item_number = f1.item_number AND f.address_number = f1.nopo
              GROUP BY f1.item_number, f1.nopo
        ) report
      GROUP BY report.brand
    ")
  end

  def self.calculation_forecasts_by_branch_and_sales(start_date, end_date, branch, channel)
    self.find_by_sql("
      SELECT report.address_number, report.sales_name, report.brand, SUM(report.forecast) as total_forecast, 	  
        ROUND((SUM(report.forecast)/DAY(LAST_DAY('#{end_date}')))*DAY('#{end_date}')) AS todate ,
        SUM(report.sales) as total_sales, report.description,
        SUM(report.realisasi_forecast) as total_realisasi_forecast FROM
        (
        SELECT IFNULL(f.sales_name, lp.salesman) as sales_name, 
              IFNULL(f.address_number, lp.nopo) as address_number, f1.item_number, f1.brand,
              IFNULL(f.quantity,0) AS forecast, a.description,
              IFNULL(lp.jumlah,0) as sales, 
              CASE 
                WHEN (lp.jumlah < 0) and (IFNULL(f.quantity, 0) = 0) THEN 0
                WHEN IFNULL(lp.jumlah,0) > IFNULL(f.quantity,0) THEN IFNULL(f.quantity,0) 
              ELSE 
                IFNULL(lp.jumlah,0) 
              END AS realisasi_forecast, 
              ((lp.jumlah/f.quantity)*100) AS acv
              FROM
              (
                SELECT DISTINCT(item_number), brand as brand, nopo FROM
                sales_mart.DETAIL_SALES_FOR_FORECASTS WHERE CAST(bp AS UNSIGNED) = '#{branch}' AND invoice_date BETWEEN '#{start_date.to_date}'
                AND '#{end_date.to_date}' and customer_type like '#{channel}%'

                UNION

                SELECT DISTINCT(item_number), brand, address_number FROM
                forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}'
                AND '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}'
                AND '#{end_date.to_date.year}'
                AND gudang_id = '#{branch}' and channel = '#{channel}'
              ) AS f1
              LEFT JOIN
              (
                SELECT SUM(total) AS jumlah, item_number, product_name, bp, panjang, lebar,
                month, year, nopo, salesman FROM
                sales_mart.DETAIL_SALES_FOR_FORECASTS  WHERE invoice_date BETWEEN '#{start_date.to_date}'
                AND '#{end_date.to_date}' and customer_type like '#{channel}%'
                GROUP BY item_number, nopo, bp, brand
              ) AS lp ON lp.item_number = f1.item_number AND (lp.nopo = f1.nopo)
              LEFT JOIN
              (
                SELECT description, brand, gudang_id, MONTH, YEAR, item_number, segment1, segment2_name,
                segment3_name, size, SUM(quantity) AS quantity, address_number, sales_name FROM
                forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}'
                AND '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}'
                AND '#{end_date.to_date.year}' and channel = '#{channel}'
                AND gudang_id = '#{branch}' GROUP BY item_number, address_number
              ) AS f ON f.item_number = f1.item_number AND f.gudang_id = '#{branch}' AND f.address_number = f1.nopo
              LEFT JOIN
              (
                SELECT * FROM gudangs
              ) AS a ON IFNULL(lp.bp, f.gudang_id) = a.code
              GROUP BY f1.item_number, f1.nopo
        ) report
      GROUP BY report.address_number, report.brand
    ")
  end

  def self.score_card(branch, from_week, to_week, year)
    find_by_sql("SELECT f.address_number , f.sales_name, f.segment2  , f.segment2_name, f.brand, f.segment3_name,
      SUM(CASE WHEN f.`size` = 000 then f.quantity else 0 end) satu ,
      SUM(CASE WHEN f.`size` = 090 then f.quantity else 0 end) dua ,
      SUM(CASE WHEN f.`size` = 100 then f.quantity else 0 end) tiga ,
      SUM(CASE WHEN f.`size` = 120 then f.quantity else 0 end) empat ,
      SUM(CASE WHEN f.`size` = 140 then f.quantity else 0 end) lima ,
      SUM(CASE WHEN f.`size` = 160 then f.quantity else 0 end) enam ,
      SUM(CASE WHEN f.`size` = 180 then f.quantity else 0 end) tujuh ,
      SUM(CASE WHEN f.`size` = 200 then f.quantity else 0 end) delapan ,
      IFNULL(rea1,0) AS rea1, IFNULL(rea2,0) AS rea2, IFNULL(rea3,0) AS rea3, IFNULL(rea4,0) AS rea4, IFNULL(rea5,0) AS rea5, 
      IFNULL(rea6,0) AS rea6, IFNULL(rea7,0) AS rea7, IFNULL(rea8,0) AS rea8,
      SUM(f.quantity) total_forecast, SUM(f.sisa) sisa, IFNULL(total, 0) as total_realisasi
      FROM forecasts f 
      LEFT JOIN 
      (
        SELECT week, year, nopo, salesman, segment1_code, segment2_code, segment3_code, month, 
          SUM(CASE WHEN rs.lebar = 000 then rs.total else 0 end) rea1 ,
          SUM(CASE WHEN rs.lebar = 090 then rs.total else 0 end) rea2 ,
          SUM(CASE WHEN rs.lebar = 100 then rs.total else 0 end) rea3 ,
          SUM(CASE WHEN rs.lebar = 120 then rs.total else 0 end) rea4 ,
          SUM(CASE WHEN rs.lebar = 140 then rs.total else 0 end) rea5 ,
          SUM(CASE WHEN rs.lebar = 160 then rs.total else 0 end) rea6 ,
          SUM(CASE WHEN rs.lebar = 180 then rs.total else 0 end) rea7 ,
          SUM(CASE WHEN rs.lebar = 200 then rs.total else 0 end) rea8 , SUM(rs.total) AS total
          FROM sales_mart.DETAIL_SALES_FOR_FORECASTS rs 
        WHERE week BETWEEN '#{from_week}' and '#{to_week}' and year = '#{year}' GROUP BY brand, segment1_code, segment2_code, segment3_code, nopo
        ) rs on f.address_number = rs.nopo AND (f.segment1 = rs.segment1_code and f.segment2  = rs.segment2_code and f.segment3 = rs.segment3_code)
      WHERE f.`week` BETWEEN '#{from_week}' and '#{to_week}' and f.`year` = '#{year}' and f.gudang_id = '#{branch}' and f.brand is not null
      GROUP BY f.address_number , f.sales_name, f.brand, f.segment1, f.segment2_name, f.segment3, f.segment3_name
      ORDER BY f.address_number ASC").group_by(&:sales_name)
  end

  def self.score_card_salesman(branch, week, year)
    find_by_sql("SELECT f.address_number , f.sales_name , f.segment2_name, f.brand, f.segment3_name,
      SUM(CASE WHEN f.`size` = 000 then f.quantity else 0 end) satu ,
      SUM(CASE WHEN f.`size` = 090 then f.quantity else 0 end) dua ,
      SUM(CASE WHEN f.`size` = 100 then f.quantity else 0 end) tiga ,
      SUM(CASE WHEN f.`size` = 120 then f.quantity else 0 end) empat ,
      SUM(CASE WHEN f.`size` = 140 then f.quantity else 0 end) lima ,
      SUM(CASE WHEN f.`size` = 160 then f.quantity else 0 end) enam ,
      SUM(CASE WHEN f.`size` = 180 then f.quantity else 0 end) tujuh ,
      SUM(CASE WHEN f.`size` = 200 then f.quantity else 0 end) delapan ,
      SUM(f.quantity) total, SUM(f.sisa) sisa
    FROM  forecasts f WHERE `week` = '#{week}' and `year` = '#{year}' and gudang_id = '#{branch}' and brand is not null
    and size in (0, 090, 100, 120, 140, 160, 180, 200)
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
      forecast = find_by(brand: row["brand"], address_number: row["address_number"].to_i, item_number: row["item_number"], branch: row["branch"], month: row["month"], year: row["year"], week: row["week"]) || new
      unless row["quantity"].nil? || row["quantity"] == 0
        if forecast.id.nil?
          item = JdeItemMaster.get_desc_forecast(row["item_number"])
          sales_name = Jde.get_sales_rkb(row["address_number"].to_i)
          gudang = Gudang.find_by_code(row["branch"])
          row["segment1"] = item.nil? ? 0 : item.imseg1.strip
          row["segment2"] = item.nil? ? 0 : item.imseg2.strip
          row["segment3"] = item.nil? ? 0 : item.imseg3.strip
          row["segment2_name"] = item.nil? ? 0 : JdeUdc.artikel_udc(item.imseg2.strip)
          row["segment3_name"] = item.nil? ? 0 : JdeUdc.kain_udc(item.imseg3.strip)
          row["size"] = item.nil? ? 0 : item.imseg6.strip
          row["description"] = item.nil? ? 'UNLISTED ITEM NUMBER' : ((item.imdsc1.nil? ? '' : item.imdsc1.strip) + ' ' + (item.imdsc2.nil? ? '' : item.imdsc2.strip))
          row["planner"] = '-'
          row["sales_name"] = sales_name.nil? ? ' ' : sales_name.abalph.strip
          row["branch"] = gudang.area_id
          row["gudang_id"] = gudang.code
          row["gudang"] = gudang.description
          row["sisa"] = row["quantity"]
          row["planner"] = item.nil? ? 0 : item.imprp4.strip
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
      SELECT f1.item_number, f.description, f.segment1, f.brand, f.month, f.year,
      lp.product_name, a.area, f.branch, f.segment2_name, f.segment3_name, IFNULL(f.sales_name, lp.salesman) as sales_name, 
      IFNULL(f.address_number, lp.nopo) as address_number,
      lp.lebar, f.size, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv, lp.segment1_code
      FROM
      (
        SELECT DISTINCT(item_number), brand as brand, nopo FROM
              sales_mart.DETAIL_SALES_FOR_FORECASTS  WHERE area_id = '#{area}' AND MONTH BETWEEN '#{start_date.to_date.month}' AND
              '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}' AND brand = '#{brand}' 

        UNION ALL

        SELECT DISTINCT(item_number), brand, address_number FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND branch = '#{area}' AND brand = '#{brand}'
      ) AS f1
      LEFT JOIN
      (
        SELECT SUM(total) AS jumlah, item_number, CONCAT(product_name,' ',panjang) as product_name, area_id, panjang, lebar, segment1_code,
              month, year, nopo, salesman FROM
              sales_mart.DETAIL_SALES_FOR_FORECASTS  WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
              '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
              AND brand = '#{brand}'
              GROUP BY item_number, nopo, area_id, brand
      ) AS lp ON lp.item_number = f1.item_number AND (lp.nopo = f1.nopo)
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
        segment3_name, size, SUM(quantity) AS quantity, address_number, sales_name FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND branch = '#{area}' GROUP BY item_number, address_number
      ) AS f ON f.item_number = f1.item_number AND f.branch = '#{area}' AND f.address_number = f1.nopo
      LEFT JOIN
      (
        SELECT * FROM areas
      ) AS a ON IFNULL(lp.area_id, f.branch) = a.id
      GROUP BY f1.item_number, f1.nopo
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
