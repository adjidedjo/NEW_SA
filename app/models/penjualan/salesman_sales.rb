class Penjualan::SalesmanSales < ActiveRecord::Base
  self.table_name = "tblaporancabang"
  def self.score_card_sales(sales)
    find_by_sql("SELECT f.brand, f.sales_name, f.segment2_name, f.segment3_name,
      (SUM(CASE WHEN f.size = '000' THEN f.sisa END)) satu,
      (SUM(CASE WHEN f.size = '090' THEN f.sisa END)) dua,
      (SUM(CASE WHEN f.size = '100' THEN f.sisa END)) tiga,
      (SUM(CASE WHEN f.size = '120' THEN f.sisa END)) empat,
      (SUM(CASE WHEN f.size = '140' THEN f.sisa END)) lima,
      (SUM(CASE WHEN f.size = '160' THEN f.sisa END)) enam,
      (SUM(CASE WHEN f.size = '180' THEN f.sisa END)) tujuh,
      (SUM(CASE WHEN f.size = '200' THEN f.sisa END)) delapan
        FROM forecasts f
        where f.`year` = '#{Date.today.year}' and f.week = '#{Date.today.cweek}' 
        and f.address_number = '#{sales.address_number}' 
        GROUP BY f.segment2, f.segment3")
  end
   
  def self.revenue_sales(sales)
    self.find_by_sql("
    SELECT sl.salesmen, sl.salesmen_desc, sl.brand, sl.qty, ot.total, sl.amount FROM (
      SELECT salesmen, salesmen_desc, brand, SUM(sales_quantity) AS qty, SUM(sales_amount) AS amount
      FROM sales_mart.RET3SALBRAND WHERE salesmen = '#{sales.address_number}' AND
      fiscal_month = '#{Date.yesterday.month}' AND fiscal_year = '#{Date.yesterday.year}' GROUP BY brand
    ) sl
    LEFT JOIN
    (
      SELECT fw.address_number, fw.brand, fw.qty_rkm, (IFNULL(fw.qty_rkm,0)+IFNULL(rh.qty_sisa,0)) AS total  FROM
      (
        SELECT address_number, brand, SUM(quantity) AS qty_rkm FROM forecast_weeklies WHERE
        address_number = '#{sales.address_number}' AND WEEK = '#{Date.yesterday.cweek}' GROUP BY brand
      ) fw
      LEFT JOIN
      (
        SELECT address_number, brand, SUM(quantity) AS qty_sisa FROM rkm_histories WHERE
        address_number = '#{sales.address_number}' AND WEEK = '#{Date.yesterday.cweek-1}' GROUP BY brand
      ) rh ON rh.brand REGEXP fw.brand
    ) ot ON ot.brand REGEXP sl.brand AND ot.address_number = sl.salesmen
    ")
  end

  def self.revenue_this_month_sales(sales, brand)
    self.find_by_sql("SELECT lc.val_1, lc.val_2, ly.v_last_year,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.v_last_year) / ly.v_last_year) * 100), 0) AS y_percentage,
    target_val,
    ROUND(((lc.val_1 / tv.target_val) * 100), 0) AS t_percentage FROM
    (
      SELECT area_id, nopo,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
      GROUP BY jenisbrgdisc
    ) as lc
      LEFT JOIN
      (
        SELECT SUM(harganetto1) AS v_last_year, area_id, nopo FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_year.beginning_of_month}'
        AND '#{Date.yesterday.last_year}' AND jenisbrgdisc REGEXP '#{brand}' AND nopo = '#{sales.address_number}' AND
        tipecust = 'RETAIL'
        GROUP BY jenisbrgdisc
      ) AS ly ON lc.nopo = '#{sales.address_number}'
      LEFT JOIN
      (
        SELECT SUM(amount) AS target_val, branch, address_number FROM sales_target_values WHERE month = '#{Date.yesterday.month}'
        AND year = '#{Date.yesterday.year}' AND brand REGEXP '#{brand}' AND address_number = '#{sales.address_number}'
        GROUP BY branch, brand
      ) AS tv ON lc.nopo = '#{sales.address_number}'
    ")
  end

  def self.sales_daily_product(sales, brand)
    self.find_by_sql("SELECT COALESCE(lc.kodejenis, 'Total') as kodejenis, lc.qty_1, lc.qty_2,
    lc.val_1, lc.val_2, ROUND(((lc.qty_1/ROUND(((SUM(st.target))/24), 0)) * 100), 0) AS target FROM
      (
        SELECT kodejenis,
        SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
        SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1,
        SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
        SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2
        FROM tblaporancabang AS lc
        WHERE tanggalsj BETWEEN '#{2.day.ago.to_date}'
        AND '#{1.day.ago.to_date}' AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{brand}' AND
        tipecust = 'RETAIL'
        GROUP BY kodejenis WITH ROLLUP
      ) AS lc
      LEFT JOIN sales_targets AS st
      ON lc.kodejenis = st.product AND st.user_id = '#{sales.id}'
      AND st.month = '#{1.day.ago.to_date.month}' GROUP BY st.product
      ")
  end

  def self.this_month_article(sales, brand)
    self.find_by_sql("SELECT namaartikel, lebar, qty_1, qty_2, val_1, val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT namaartikel, lebar,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN jumlah END) qty_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
      GROUP BY namaartikel, lebar
      ) as sub")
  end

  def self.this_month_customer(sales, brand)
    self.find_by_sql("SELECT customer, kodejenis, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT customer, kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'KM' THEN jumlah END) km,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'DV' THEN jumlah END) dv,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'HB' THEN jumlah END) hb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'SA' THEN jumlah END) sa,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'SB' THEN jumlah END) sb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'KB' THEN jumlah END) kb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN harganetto1 END) total_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
      GROUP BY customer
      ) as sub")
  end

  def self.this_month_city(sales, brand)
    self.find_by_sql("SELECT kota, kodejenis, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT kota, kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'KM' THEN jumlah END) km,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'DV' THEN jumlah END) dv,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'HB' THEN jumlah END) hb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'SA' THEN jumlah END) sa,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'SB' THEN jumlah END) sb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'KB' THEN jumlah END) kb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN harganetto1 END) total_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
      GROUP BY kota
      ) as sub")
  end

  def self.this_week(sales, brand)
    self.find_by_sql("SELECT COALESCE(kodejenis, 'Total') as kodejenis, qty_1, qty_2, val_1, val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_week}'
      AND '#{Date.yesterday}' THEN jumlah END) qty_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_week}'
      AND '#{Date.yesterday}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_week.beginning_of_week}'
      AND '#{Date.yesterday.last_week}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_week.beginning_of_week}'
      AND '#{Date.yesterday.last_week}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_week.beginning_of_week}'
      AND '#{Date.yesterday}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
      GROUP BY kodejenis WITH ROLLUP
      ) as sub")
  end

  def self.this_month(sales, brand)
    self.find_by_sql("SELECT COALESCE(lc.kodejenis, 'Total') as kodejenis, lc.qty_1, lc.qty_2,
    lc.val_1, lc.val_2, ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND(((lc.qty_1/SUM(st.target)) * 100.0), 0) AS target,
    (SUM(st.target)-lc.qty_1) AS rot FROM
    (
      SELECT kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN jumlah END) qty_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
      GROUP BY kodejenis WITH ROLLUP
      ) as lc
      LEFT JOIN sales_targets AS st
      ON lc.kodejenis = st.product AND (st.user_id = '#{sales.id}' OR st.user_id IS NULL)
      AND (st.month = '#{1.day.ago.to_date.month}' OR st.month IS NULL)
      AND (st.year = '#{1.day.ago.to_date.year}' OR st.year IS NULL) GROUP BY st.product
      ")
  end

  def self.last_month_article(sales)
    self.find_by_sql("SELECT namaartikel, lebar, qty_1, qty_2, val_1, val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT namaartikel, lebar,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' THEN jumlah END) qty_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}'
      AND '#{2.month.ago.to_date.end_of_month}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}'
      AND '#{2.month.ago.to_date.end_of_month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{sales.brand1}' AND
      tipecust = 'RETAIL'
      GROUP BY namaartikel, lebar
      ) as sub")
  end

  def self.last_month_customer(sales)
    self.find_by_sql("SELECT customer, kodejenis, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT customer, kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' AND kodejenis = 'KM' THEN jumlah END) km,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' AND kodejenis = 'DV' THEN jumlah END) dv,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' AND kodejenis = 'HB' THEN jumlah END) hb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' AND kodejenis = 'SA' THEN jumlah END) sa,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' AND kodejenis = 'SB' THEN jumlah END) sb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' AND kodejenis = 'KB' THEN jumlah END) kb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}'
      AND '#{2.month.ago.to_date.end_of_month}' THEN harganetto1 END) total_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{sales.brand1}' AND
      tipecust = 'RETAIL'
      GROUP BY customer
      ) as sub")
  end

  def self.last_month_city(sales)
    self.find_by_sql("SELECT kota, kodejenis, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT kota, kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' AND kodejenis = 'KM' THEN jumlah END) km,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' AND kodejenis = 'DV' THEN jumlah END) dv,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' AND kodejenis = 'HB' THEN jumlah END) hb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' AND kodejenis = 'SA' THEN jumlah END) sa,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' AND kodejenis = 'SB' THEN jumlah END) sb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' AND kodejenis = 'KB' THEN jumlah END) kb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}'
      AND '#{2.month.ago.to_date.end_of_month}' THEN harganetto1 END) total_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{sales.brand1}' AND
      tipecust = 'RETAIL'
      GROUP BY kota
      ) as sub")
  end

  def self.last_month(sales)
    self.find_by_sql("SELECT COALESCE(kodejenis, 'Total') as kodejenis, qty_1, qty_2, val_1, val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' THEN jumlah END) qty_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}'
      AND '#{2.month.ago.to_date.end_of_month}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}'
      AND '#{2.month.ago.to_date.end_of_month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}'
      AND '#{1.month.ago.to_date.end_of_month}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{sales.brand1}' AND
      tipecust = 'RETAIL'
      GROUP BY kodejenis WITH ROLLUP
      ) as sub")
  end

  #########################################

  def self.last_week_article(sales)
    self.find_by_sql("SELECT namaartikel, lebar, qty_1, qty_2, val_1, val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT namaartikel, lebar,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' THEN jumlah END) qty_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.weeks.ago.to_date.beginning_of_week}'
      AND '#{2.week.ago.to_date.end_of_week}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.weeks.ago.to_date.beginning_of_week}'
      AND '#{2.week.ago.to_date.end_of_week}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{2.weeks.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}'
      AND nopo = '#{sales.address_number}' AND
      tipecust = 'RETAIL'
      GROUP BY namaartikel, lebar
      ) as sub")
  end

  def self.last_week_customer(sales)
    self.find_by_sql("SELECT customer, kodejenis, km, dv, hb, sa, sb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT customer, kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' AND kodejenis = 'KM' THEN jumlah END) km,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' AND kodejenis = 'DV' THEN jumlah END) dv,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' AND kodejenis = 'HB' THEN jumlah END) hb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' AND kodejenis = 'SA' THEN jumlah END) sa,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' AND kodejenis = 'SB' THEN jumlah END) sb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.weeks.ago.to_date.beginning_of_week}'
      AND '#{2.weeks.ago.to_date.end_of_week}' THEN harganetto1 END) total_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{2.weeks.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}'
      AND nopo = '#{sales.address_number}' AND
      tipecust = 'RETAIL'
      GROUP BY customer
      ) as sub")
  end

  def self.last_week_city(sales)
    self.find_by_sql("SELECT kota, kodejenis, km, dv, hb, sa, sb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT kota, kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' AND kodejenis = 'KM' THEN jumlah END) km,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' AND kodejenis = 'DV' THEN jumlah END) dv,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' AND kodejenis = 'HB' THEN jumlah END) hb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' AND kodejenis = 'SA' THEN jumlah END) sa,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' AND kodejenis = 'SB' THEN jumlah END) sb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.weeks.ago.to_date.beginning_of_week}'
      AND '#{2.weeks.ago.to_date.end_of_week}' THEN harganetto1 END) total_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{2.weeks.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}'
      AND nopo = '#{sales.address_number}' AND
      tipecust = 'RETAIL'
      GROUP BY kota
      ) as sub")
  end

  def self.last_week(sales)
    self.find_by_sql("SELECT COALESCE(kodejenis, 'Total') as kodejenis, qty_1, qty_2, val_1, val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' THEN jumlah END) qty_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.weeks.ago.to_date.beginning_of_week}'
      AND '#{2.weeks.ago.to_date.end_of_week}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.weeks.ago.to_date.beginning_of_week}'
      AND '#{2.weeks.ago.to_date.end_of_week}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{2.weeks.ago.to_date.beginning_of_week}'
      AND '#{1.week.ago.to_date.end_of_week}'
      AND nopo = '#{sales.address_number}' AND
      tipecust = 'RETAIL'
      GROUP BY kodejenis WITH ROLLUP
      ) as sub")
  end

  ####################################

  def self.sales_daily_product(sales, brand)
    self.find_by_sql("SELECT COALESCE(lc.kodejenis, 'Total') as kodejenis, lc.qty_1, lc.qty_2,
    lc.val_1, lc.val_2, ROUND(((lc.qty_1/ROUND(((SUM(st.target))/24), 0)) * 100), 0) AS target FROM
      (
        SELECT kodejenis,
        SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
        SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1,
        SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
        SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2
        FROM tblaporancabang AS lc
        WHERE tanggalsj BETWEEN '#{2.day.ago.to_date}'
        AND '#{1.day.ago.to_date}' AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{brand}' AND
        tipecust = 'RETAIL'
        GROUP BY kodejenis WITH ROLLUP
      ) AS lc
      LEFT JOIN sales_targets AS st
      ON lc.kodejenis = st.product AND st.user_id = '#{sales.id}'
      AND st.month = '#{1.day.ago.to_date.month}' GROUP BY st.product
      ")
  end

  def self.this_month_article(sales, brand)
    self.find_by_sql("SELECT namaartikel, lebar, qty_1, qty_2, val_1, val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT namaartikel, lebar,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN jumlah END) qty_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
      GROUP BY namaartikel, lebar
      ) as sub")
  end

  def self.this_month_customer(sales, brand)
    self.find_by_sql("SELECT customer, kodejenis, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT customer, kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'KM' THEN jumlah END) km,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'DV' THEN jumlah END) dv,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'HB' THEN jumlah END) hb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'SA' THEN jumlah END) sa,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'SB' THEN jumlah END) sb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'KB' THEN jumlah END) kb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN harganetto1 END) total_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
      GROUP BY customer
      ) as sub")
  end

  def self.this_month_city(sales, brand)
    self.find_by_sql("SELECT kota, kodejenis, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT kota, kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'KM' THEN jumlah END) km,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'DV' THEN jumlah END) dv,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'HB' THEN jumlah END) hb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'SA' THEN jumlah END) sa,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'SB' THEN jumlah END) sb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND kodejenis = 'KB' THEN jumlah END) kb,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN harganetto1 END) total_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
      GROUP BY kota
      ) as sub")
  end

  def self.this_week(sales, brand)
    self.find_by_sql("SELECT COALESCE(kodejenis, 'Total') as kodejenis, qty_1, qty_2, val_1, val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_week}'
      AND '#{Date.yesterday}' THEN jumlah END) qty_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_week}'
      AND '#{Date.yesterday}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_week.beginning_of_week}'
      AND '#{Date.yesterday.last_week}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_week.beginning_of_week}'
      AND '#{Date.yesterday.last_week}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_week.beginning_of_week}'
      AND '#{Date.yesterday}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
      GROUP BY kodejenis WITH ROLLUP
      ) as sub")
  end

  def self.this_month(sales, brand)
    self.find_by_sql("SELECT COALESCE(lc.kodejenis, 'Total') as kodejenis, lc.qty_1, lc.qty_2,
    lc.val_1, lc.val_2, ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND(((lc.qty_1/SUM(st.target)) * 100.0), 0) AS target,
    (SUM(st.target)-lc.qty_1) AS rot FROM
    (
      SELECT kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN jumlah END) qty_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
      GROUP BY kodejenis WITH ROLLUP
      ) as lc
      LEFT JOIN sales_targets AS st
      ON lc.kodejenis = st.product AND (st.user_id = '#{sales.id}' OR st.user_id IS NULL)
      AND (st.month = '#{1.day.ago.to_date.month}' OR st.month IS NULL)
      AND (st.year = '#{1.day.ago.to_date.year}' OR st.year IS NULL) GROUP BY st.product
      ")
  end
end
