class Penjualan::SalesStockRate < ActiveRecord::Base
  self.table_name = "tblaporancabang"
  
  #WEEKLY
  
  def self.sales_stock_rate_weekly_summary(branch, brand)
    self.find_by_sql("SELECT CONCAT('WEEK ', lc.week) AS weekly_name, 
    ROUND(((lc.jumlah + (IFNULL(st.qty,0))/lc.jumlah)), 2) AS ssr FROM
    (
      SELECT cabang_id, week, SUM(jumlah) AS jumlah 
      FROM tblaporancabang WHERE week BETWEEN '#{4.week.ago.to_date.cweek}' 
      AND '#{1.week.ago.to_date.cweek}' AND fiscal_year BETWEEN '#{4.week.ago.year}' 
      AND '#{1.week.ago.year}' AND jenisbrgdisc = '#{brand}' AND cabang_id = '#{branch}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'KB') GROUP BY week
      ) as lc
      LEFT JOIN 
      (
       SELECT branch, week, SUM(qty) AS qty
       FROM bom_stocks WHERE week BETWEEN '#{4.weeks.ago.to_date.cweek}' AND '#{1.weeks.ago.to_date.cweek}'
       AND fiscal_year BETWEEN '#{4.weeks.ago.to_date.year}' AND '#{1.weeks.ago.to_date.year}'
       AND brand = '#{brand}' AND branch = '#{branch}' AND product IN ('KM', 'DV', 'HB', 'KB') GROUP BY week
      ) AS st
      ON lc.week = st.week")
  end
  
  def self.sales_stock_rate_weekly_product(branch, brand)
    self.find_by_sql("SELECT lc.kodejenis AS product, 
    ROUND((((IFNULL(st.qty,0) + lc.jumlah)/lc.jumlah)), 2) AS ssr,
    ROUND(((lc.jumlah/(IFNULL(st.qty,0) + lc.jumlah)) * 100)) AS str,
    lc.jumlah, (st.qty + lc.jumlah) AS qty FROM
    (
      SELECT cabang_id, kodejenis, SUM(jumlah) AS jumlah 
      FROM tblaporancabang WHERE week = '#{1.week.ago.to_date.cweek}' AND fiscal_year = '#{1.week.ago.to_date.year}'
      AND jenisbrgdisc = '#{brand}' AND cabang_id = '#{branch}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'KB') GROUP BY kodejenis
      ) as lc
      LEFT JOIN 
      (
       SELECT branch, product, SUM(qty) AS qty
       FROM bom_stocks WHERE week = '#{Date.today.cweek}'
       AND fiscal_year = '#{Date.today.year}'
       AND brand = '#{brand}' AND branch = '#{branch}' GROUP BY product
      ) AS st
      ON lc.kodejenis = st.product")
  end
end