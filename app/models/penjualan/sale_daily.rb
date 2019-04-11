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
      AND area_id = '#{branch}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
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
      SELECT branch,
      SUM(CASE WHEN fiscal_month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}' AND
        '#{Date.yesterday.month}'  THEN sales_amount END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.month}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.month}' AND
        product IN ('KM', 'DV', 'HB', 'KB') THEN sales_amount END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN sales_amount END) val_2
      FROM sales_mart.RET1PRODUCT WHERE fiscal_month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}'
      AND '#{Date.yesterday.month}' AND fiscal_year BETWEEN '#{Date.yesterday.last_month.year}'
      AND '#{Date.yesterday.year}' AND branch = '#{branch}' AND brand REGEXP '#{brand}'
      GROUP BY brand
    ) as lc
      LEFT JOIN
      (
        SELECT SUM(sales_amount) AS v_last_year, branch FROM sales_mart.RET1BRAND WHERE
        fiscal_month = '#{Date.yesterday.last_year.month}' AND
        fiscal_year = '#{Date.yesterday.last_year.year}'
        AND brand REGEXP '#{brand}' AND branch = '#{branch}'
        GROUP BY brand
      ) AS ly ON lc.branch = '#{branch}'
      LEFT JOIN
      (
        SELECT branch,
        SUM(CASE WHEN month = '#{Date.yesterday.month}' THEN target END) target_val,
        SUM(CASE WHEN month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}' AND
        '#{Date.yesterday.end_of_year.month}' THEN target END) year_target
        FROM sales_target_values WHERE
        branch = '#{branch}' AND
        (brand REGEXP '#{brand}' OR brand IS NULL)
        AND month BETWEEN '#{Date.yesterday.beginning_of_year.month}' AND
        '#{Date.yesterday.end_of_year.month}'
        AND (year = '#{Date.yesterday.year}' OR year IS NULL)
      ) AS st ON lc.branch = st.branch
    ")
  end

  def self.sales_daily_product(branch, brand)
    self.find_by_sql("SELECT COALESCE(kodejenis, 'Total') as kodejenis,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{2.day.ago.to_date}'
      AND '#{1.day.ago.to_date}' AND area_id = '#{branch}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
      GROUP BY kodejenis WITH ROLLUP")
  end

  def self.this_month_salesman(branch, brand)
    self.find_by_sql("SELECT lc.salesmen_desc as salesman, lc.qty_1, lc.qty_2, lc.val_1, lc.val_2,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND(((lc.qty_1/SUM(st.target)) * 100.0), 0) AS target,
    (SUM(st.target)-lc.qty_1) AS rot FROM
    (
      SELECT salesmen_desc, salesmen,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN sales_amount END) val_1,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN sales_quantity END) qty_2,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN sales_amount END) val_2
      FROM sales_mart.RET3SALBRAND WHERE date BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND branch = '#{branch}' AND brand REGEXP '#{brand}'
      GROUP BY salesmen
      ) as lc
      LEFT JOIN sales_targets st
      ON (st.address_number = lc.salesmen) AND st.brand REGEXP '#{brand}'
      AND st.month = '#{Date.yesterday.month}'
      AND st.year = '#{Date.yesterday.year}' GROUP BY lc.salesmen
      ")
  end

  def self.this_month_article(branch, brand)
    self.find_by_sql("SELECT article_desc as namaartikel, size as lebar, qty_1, qty_2, val_1, val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT article_desc, size,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN sales_amount END) val_1,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN sales_quantity END) qty_2,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN sales_amount END) val_2
      FROM sales_mart.RET1ARTICLE WHERE date BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND branch = '#{branch}' AND brand REGEXP '#{brand}'
      GROUP BY article, size
      ) as sub")
  end

  def self.this_month_customer(branch, brand)
    self.find_by_sql("SELECT customer_desc as customer, product as kodejenis, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT customer_desc, product,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND product = 'KM' THEN sales_quantity END) km,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND product = 'DV' THEN sales_quantity END) dv,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND product = 'HB' THEN sales_quantity END) hb,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND product = 'SA' THEN sales_quantity END) sa,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND product = 'SB' THEN sales_quantity END) sb,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND product = 'KB' THEN sales_quantity END) kb,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN sales_amount END) total_1,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN sales_amount END) total_2
      FROM sales_mart.RET2CUSPRODUCT WHERE date BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND branch = '#{branch}' AND brand REGEXP '#{brand}'
      GROUP BY customer
      ) as sub")
  end

  def self.this_month_city(branch, brand)
    self.find_by_sql("SELECT city as kota, product as kodejenis, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT city, product,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND product = 'KM' THEN sales_quantity END) km,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND product = 'DV' THEN sales_quantity END) dv,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND product = 'HB' THEN sales_quantity END) hb,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND product = 'SA' THEN sales_quantity END) sa,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND product = 'SB' THEN sales_quantity END) sb,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' AND product = 'KB' THEN sales_quantity END) kb,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN sales_amount END) total_1,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN sales_amount END) total_2
      FROM sales_mart.RET4CITYPRODUCT WHERE date BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND branch = '#{branch}' AND brand REGEXP '#{brand}'
      GROUP BY city
      ) as sub")
  end

  def self.this_month(branch, brand)
    self.find_by_sql("SELECT lc.product as kodejenis, lc.qty_1, lc.qty_2, lc.val_1, lc.val_2,
    ROUND((((lc.val_1 - lc.val_2) /lc. val_2) * 100), 0) AS percentage,
    ROUND(((lc.qty_1/SUM(st.target)) * 100.0), 0) AS target,
    (SUM(st.target)-lc.qty_1) AS rot FROM
    (
      SELECT product,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_month}'
      AND '#{Date.yesterday}' THEN sales_amount END) val_1,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN sales_quantity END) qty_2,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN sales_amount END) val_2
      FROM sales_mart.RET1PRODUCT WHERE date BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday}'
      AND branch = '#{branch}' AND brand REGEXP '#{brand}'
      GROUP BY product
      ) as lc
      LEFT JOIN sales_targets AS st
      ON lc.product = st.product AND (st.brand REGEXP '#{brand}' OR st.brand IS NULL) AND
      (st.branch = '#{branch}' OR st.branch IS NULL)
      AND (st.month = '#{Date.yesterday.month}' OR st.month IS NULL)
      AND (st.year = '#{Date.yesterday.year}' OR st.year IS NULL) GROUP BY st.product
      ")
  end

  def self.this_week(branch, brand)
    self.find_by_sql("SELECT COALESCE(sub.product, 'Total') as kodejenis, qty_1, qty_2, val_1, val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT product,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_week}'
      AND '#{Date.yesterday}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.beginning_of_week}'
      AND '#{Date.yesterday}' THEN sales_amount END) val_1,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.last_week.beginning_of_week}'
      AND '#{Date.yesterday.last_week}' THEN sales_quantity END) qty_2,
      SUM(CASE WHEN date BETWEEN '#{Date.yesterday.last_week.beginning_of_week}'
      AND '#{Date.yesterday.last_week}' THEN sales_amount END) val_2
      FROM sales_mart.RET1PRODUCT WHERE date BETWEEN '#{Date.yesterday.last_week.beginning_of_week}'
      AND '#{Date.yesterday}'
      AND branch = '#{branch}' AND brand REGEXP '#{brand}'
      GROUP BY product WITH ROLLUP
      ) as sub")
  end

  def self.daily_product(branch, brand)
    self.find_by_sql("SELECT product,
      SUM(CASE WHEN date = '#{2.day.ago.to_date}' THEN sales_quantity END) AS qty_2,
      SUM(CASE WHEN date = '#{2.day.ago.to_date}' THEN sale_amount END) AS val_2,
      SUM(CASE WHEN date = '#{1.day.ago.to_date}' THEN sales_quantity END) AS qty_1,
      SUM(CASE WHEN date = '#{1.day.ago.to_date}' THEN sales_amount END) AS val_1
      FROM sales_mart.RET1PRODUCT WHERE branch = '#{branch}' AND date BETWEEN '#{2.day.ago.to_date}' AND '#{1.day.ago.to_date}'
      AND brand REGEXP '#{brand}' GROUP BY product")
  end

  def self.daily_summary(branch, brand)
    self.find_by_sql("SELECT date, SUM(sales_quantity) AS jumlah, SUM(sales_amount) AS price
    FROM sales_mart.RET1BRAND WHERE branch = '#{branch}' AND
    date BETWEEN '#{6.day.ago.to_date}' AND '#{1.day.ago.to_date}' AND brand REGEXP '#{brand}' GROUP BY date")
  end

  def self.daily_salesman(branch, brand)
    self.find_by_sql("SELECT salesman,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1
      FROM tblaporancabang WHERE area_id = '#{branch}' AND tanggalsj BETWEEN '#{2.day.ago.to_date}' AND '#{1.day.ago.to_date}'
      AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'   GROUP BY salesman")
  end

  def self.daily_customer(branch, brand)
    self.find_by_sql("SELECT kode_customer, customer, salesman,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1
      FROM tblaporancabang WHERE area_id = '#{branch}' AND tanggalsj BETWEEN '#{2.day.ago.to_date}' AND '#{1.day.ago.to_date}'
      AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'   GROUP BY kode_customer")
  end
end