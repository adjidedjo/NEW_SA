class Penjualan::SaleDaily < Penjualan::Sale
  self.table_name = "tblaporancabang"
  def self.on_time_delivery(branch, brand)
    self.find_by_sql("SELECT ((variance1/total_so) * 100) AS ontime, ((variance2/total_so) * 100) AS late,
    ((variance3/total_so) * 100) AS superlate, total_so FROM
    (
      SELECT diskon5,
      COUNT(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND diskon5 <= 3 THEN diskon5 END) variance1,
      COUNT(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND diskon5 BETWEEN 4 AND 7 THEN diskon5 END) variance2,
      COUNT(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND diskon5 > 7 THEN diskon5 END) variance3,
      COUNT(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN diskon5 END) total_so
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' 
      ) as sub")
  end

  def self.revenue_this_month(branch, brand)
    self.find_by_sql("SELECT lc.val_1, lc.val_2, ly.v_last_year,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.v_last_year) / ly.v_last_year) * 100), 0) AS y_percentage,
    target_val,
    ROUND(((lc.val1_1 / st.target_val) * 100), 0) AS t_percentage,
    ROUND(((lc.y_qty / st.year_target) * 100), 0) AS ty_percentage FROM
    (
      SELECT area_id,
      SUM(CASE WHEN fiscal_month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}' AND
        '#{Date.yesterday.month}'  THEN harganetto1 END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.month}' AND
        kodejenis IN ('KM', 'DV', 'HB', 'KB') THEN harganetto1 END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}'
      AND '#{Date.yesterday.month}' AND fiscal_year BETWEEN '#{Date.yesterday.last_month.year}'
      AND '#{Date.yesterday.year}' AND area_id != 1 AND area_id != 50
      AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' 
      GROUP BY jenisbrgdisc
    ) as lc
      LEFT JOIN
      (
        SELECT SUM(harganetto1) AS v_last_year, area_id FROM tblaporancabang WHERE
        fiscal_month = '#{Date.yesterday.last_year.month}' AND
        fiscal_year = '#{Date.yesterday.last_year.year}'
        AND jenisbrgdisc = '#{brand}' AND area_id != 1 AND jenisbrgdisc = '#{brand}' AND area_id = '#{branch}' AND
        tipecust = 'RETAIL' AND bonus = '-' 
        GROUP BY jenisbrgdisc
      ) AS ly ON lc.area_id = '#{branch}'
      LEFT JOIN
      (
        SELECT branch,
        SUM(CASE WHEN month = '#{Date.yesterday.month}' THEN target END) target_val,
        SUM(CASE WHEN month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}' AND
        '#{Date.yesterday.end_of_year.month}' THEN target END) year_target
        FROM sales_target_values WHERE
        branch = '#{branch}' AND
        (brand = '#{brand}' OR brand IS NULL)
        AND month BETWEEN '#{Date.yesterday.beginning_of_year.month}' AND
        '#{Date.yesterday.end_of_year.month}'
        AND (year = '#{Date.yesterday.year}' OR year IS NULL)
      ) AS st ON lc.area_id = st.branch
    ")
  end

  def self.sales_daily_product(branch, brand)
    self.find_by_sql("SELECT COALESCE(kodejenis, 'Total') as kodejenis,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{2.day.ago.to_date}'
      AND '#{1.day.ago.to_date}' AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' 
      GROUP BY kodejenis WITH ROLLUP")
  end

  def self.this_month_salesman(branch, brand)
    self.find_by_sql("SELECT lc.salesman, lc.qty_1, lc.qty_2, lc.val_1, lc.val_2,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND(((lc.qty_1/SUM(st.target)) * 100.0), 0) AS target,
    (SUM(st.target)-lc.qty_1) AS rot FROM
    (
      SELECT salesman, nopo,
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
      AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-'  AND nopo != '-'
      GROUP BY nopo
      ) as lc
      LEFT JOIN sales_targets st
      ON (st.address_number = lc.nopo) AND st.brand = '#{brand}'
      AND st.month = '#{Date.yesterday.month}'
      AND st.year = '#{Date.yesterday.year}' GROUP BY lc.nopo
      ")
  end

  def self.this_month_article(branch, brand)
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
      AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' 
      GROUP BY namaartikel, lebar
      ) as sub")
  end

  def self.this_month_customer(branch, brand)
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
      AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' 
      GROUP BY customer
      ) as sub")
  end

  def self.this_month_city(branch, brand)
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
      AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' 
      GROUP BY kota
      ) as sub")
  end

  def self.this_month(branch, brand)
    self.find_by_sql("SELECT lc.kodejenis, lc.qty_1, lc.qty_2, lc.val_1, lc.val_2,
    ROUND((((lc.val_1 - lc.val_2) /lc. val_2) * 100), 0) AS percentage,
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
      AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' 
      GROUP BY kodejenis
      ) as lc
      LEFT JOIN sales_targets AS st
      ON lc.kodejenis = st.product AND (st.brand = '#{brand}' OR st.brand IS NULL) AND
      (st.branch = '#{branch}' OR st.branch IS NULL)
      AND (st.month = '#{Date.yesterday.month}' OR st.month IS NULL)
      AND (st.year = '#{Date.yesterday.year}' OR st.year IS NULL) GROUP BY st.product
      ")
  end

  def self.this_week(branch, brand)
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
      AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' 
      GROUP BY kodejenis WITH ROLLUP
      ) as sub")
  end

  def self.daily_summary(branch, brand)
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah
    FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{6.day.ago.to_date}' AND '#{1.day.ago.to_date}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-'  GROUP BY tanggalsj")
  end

  def self.daily_product(branch, brand)
    self.find_by_sql("SELECT kodejenis,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1
      FROM tblaporancabang WHERE area_id = '#{branch}' AND tanggalsj BETWEEN '#{2.day.ago.to_date}' AND '#{1.day.ago.to_date}'
      AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-'  GROUP BY kodejenis")
  end

  def self.daily_summary(branch, brand)
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{6.day.ago.to_date}' AND '#{1.day.ago.to_date}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-'  GROUP BY tanggalsj")
  end

  def self.daily_salesman(branch, brand)
    self.find_by_sql("SELECT salesman,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1
      FROM tblaporancabang WHERE area_id = '#{branch}' AND tanggalsj BETWEEN '#{2.day.ago.to_date}' AND '#{1.day.ago.to_date}'
      AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-'  GROUP BY salesman")
  end

  def self.daily_customer(branch, brand)
    self.find_by_sql("SELECT kode_customer, customer, salesman,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1
      FROM tblaporancabang WHERE area_id = '#{branch}' AND tanggalsj BETWEEN '#{2.day.ago.to_date}' AND '#{1.day.ago.to_date}'
      AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-'  GROUP BY kode_customer")
  end
end