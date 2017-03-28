class Penjualan::Sale < ActiveRecord::Base
  self.table_name = "tblaporancabang"
  ########## START MONTHLY

  def self.monthly_article_summary(branch, brand)
    self.find_by_sql("SELECT namaartikel, lebar, qty_1, qty_2, val_1, val_2, 
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT namaartikel, lebar,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN jumlah END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.last_month.month}' THEN jumlah END) qty_2,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.last_month.month}' THEN harganetto1 END) val_2      
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{Date.yesterday.last_month.last_month.month}' 
      AND '#{Date.yesterday.last_month.month}' AND fiscal_year BETWEEN '#{Date.yesterday.last_month.last_month.year}' 
      AND '#{Date.yesterday.last_month.year}' AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'KB') 
      GROUP BY namaartikel, lebar
      ) as sub")
  end
  
  def self.monthly_city_summary(branch, brand)
    self.find_by_sql("SELECT kota, kodejenis, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT kota, kodejenis,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND kodejenis = 'KM' THEN jumlah END) km,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND kodejenis = 'HB' THEN jumlah END) hb,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND kodejenis = 'DV' THEN jumlah END) dv,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND kodejenis = 'SA' THEN jumlah END) sa,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND kodejenis = 'SB' THEN jumlah END) sb,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND kodejenis = 'KB' THEN jumlah END) kb,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.last_month.month}' THEN harganetto1 END) total_2    
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{Date.yesterday.last_month.last_month.month}' 
      AND '#{Date.yesterday.last_month.month}' AND fiscal_year BETWEEN '#{Date.yesterday.last_month.last_month.year}' 
      AND '#{Date.yesterday.last_month.year}' AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY kota
      ) as sub")
  end
  
  def self.monthly_customer_summary(branch, brand)
    self.find_by_sql("SELECT customer, kodejenis, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT customer, kodejenis,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND kodejenis = 'KM' THEN jumlah END) km,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND kodejenis = 'HB' THEN jumlah END) hb,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND kodejenis = 'DV' THEN jumlah END) dv,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND kodejenis = 'SA' THEN jumlah END) sa,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND kodejenis = 'SB' THEN jumlah END) sb,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND kodejenis = 'KB' THEN jumlah END) kb,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.last_month.month}' THEN harganetto1 END) total_2    
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{Date.yesterday.last_month.last_month.month}' 
      AND '#{Date.yesterday.last_month.month}' AND fiscal_year BETWEEN '#{Date.yesterday.last_month.last_month.year}' 
      AND '#{Date.yesterday.last_month.year}' AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY customer
      ) as sub")
  end
  
  def self.revenue_last_month(branch, brand)
    self.find_by_sql("SELECT lc.val_1, lc.val_2, ly.revenue,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage FROM
    (
      SELECT cabang_id,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.last_month.month}' THEN harganetto1 END) val_2      
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{Date.yesterday.last_month.last_month.month}' 
      AND '#{Date.yesterday.last_month.month}' AND fiscal_year BETWEEN '#{Date.yesterday.last_month.last_month.year}' 
      AND '#{Date.yesterday.last_month.year}' AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY jenisbrgdisc
    ) as lc
      LEFT JOIN 
      (
        SELECT SUM(harganetto1) AS revenue, cabang_id FROM tblaporancabang WHERE 
        fiscal_month = '#{Date.yesterday.last_month.last_year.month}' AND fiscal_year = '#{Date.yesterday.last_month.last_year.year}' 
        AND jenisbrgdisc = '#{brand}' AND cabang_id = '#{branch}' AND
        tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
        GROUP BY jenisbrgdisc
      ) AS ly ON lc.cabang_id = '#{branch}'
    ")
  end
  
  def self.monthly_summaries(branch, brand)
    self.find_by_sql("SELECT SUM(harganetto1) AS jumlah, fiscal_month FROM tblaporancabang 
    WHERE cabang_id = '#{branch}' AND fiscal_month BETWEEN '#{1.month.ago.beginning_of_year.month}' 
    AND '#{Date.yesterday.month}' AND fiscal_year = '#{1.month.ago.beginning_of_year.year}'
    AND tipecust = 'RETAIL' AND jenisbrgdisc = '#{brand}' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
    GROUP BY fiscal_month, cabang_id")
  end
  
  def self.monthly_product_summary(branch, brand)
    self.find_by_sql("SELECT lc.kodejenis, lc.qty_1, lc.qty_2, lc.val_1, lc.val_2, 
    ROUND((((lc.val_1 - lc.val_2) /lc. val_2) * 100), 0) AS percentage,
    ROUND(((lc.qty_1/SUM(st.target)) * 100.0), 0) AS target FROM
    (
      SELECT kodejenis,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN jumlah END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.last_month.month}' THEN jumlah END) qty_2,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.last_month.month}' THEN harganetto1 END) val_2      
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{Date.yesterday.last_month.last_month.month}' 
      AND '#{Date.yesterday.last_month.month}' AND fiscal_year BETWEEN '#{Date.yesterday.last_month.last_month.year}' 
      AND '#{Date.yesterday.last_month.year}' AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY kodejenis
      ) as lc
      LEFT JOIN sales_targets AS st
      ON lc.kodejenis = st.product AND (st.brand = '#{brand}' OR st.brand IS NULL) AND 
      (st.branch = '#{branch}' OR st.branch IS NULL)
      AND (st.month = '#{Date.yesterday.last_month.month}' OR st.month IS NULL) 
      AND (st.year = '#{Date.yesterday.last_month.year}' OR st.year IS NULL) GROUP BY st.product
      ")
  end

  def self.monthly_summary(branch, brand)
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    MONTH(tanggalsj) = '#{Date.today.month}' AND YEAR(tanggalsj) = '#{Date.today.year}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end
  ########## END MONTHLY

  ########## MOST ITEMS
  def self.most_items_ordered_weekly(branch, brand)
    beginning_of_week = 1.week.ago.to_date.beginning_of_week.to_date
    end_of_week = 1.week.ago.to_date.end_of_week.to_date
    self.find_by_sql("SELECT namaartikel, lebar, ordered, value FROM (
    SELECT kodejenis, namaartikel, lebar, SUM(jumlah) AS ordered, SUM(harganetto1) AS value FROM tblaporancabang
    WHERE cabang_id = '#{branch}' AND tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}'
    AND tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') AND jenisbrgdisc = '#{brand}' GROUP BY namaartikel) totals
    GROUP BY namaartikel, lebar ORDER BY ordered DESC LIMIT 10")
  end

  def self.most_items_ordered_monthly(branch, brand)
    self.find_by_sql("SELECT namaartikel, ordered, lebar, value FROM (
    SELECT kodejenis, namaartikel, lebar, SUM(jumlah) AS ordered, SUM(harganetto1) AS value FROM tblaporancabang
    WHERE cabang_id = '#{branch}' AND MONTH(tanggalsj) = '#{1.month.ago.to_date.month}' AND 
    YEAR(tanggalsj) = '#{1.month.ago.to_date.year}' AND tipecust = 'RETAIL' AND bonus = '-' AND 
    kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') AND jenisbrgdisc = '#{brand}' 
    GROUP BY namaartikel, lebar) totals ORDER BY ordered DESC LIMIT 10")
  end
  ########## END MOST ITEMS

  ########## CUSTOMER
  def self.customer_summary_monthly(branch, brand)
    self.find_by_sql("SELECT customer, salesman, SUM(jumlah) AS ordered, SUM(harganetto1) AS price,
    jenisbrgdisc FROM tblaporancabang WHERE cabang_id = '#{branch}' AND MONTH(tanggalsj) = '#{1.month.ago.to_date.month}' AND
    YEAR(tanggalsj) = '#{1.month.ago.to_date.year}' AND tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') AND jenisbrgdisc = '#{brand}' GROUP BY customer")
  end

  def self.customer_summary(branch, brand)
    beginning_of_week = 1.week.ago.to_date.beginning_of_week.to_date
    end_of_week = 1.week.ago.to_date.end_of_week.to_date
    self.find_by_sql("SELECT customer, salesman, SUM(jumlah) AS ordered, SUM(harganetto1) AS price,
    jenisbrgdisc FROM tblaporancabang WHERE cabang_id = '#{branch}' AND tanggalsj BETWEEN '#{beginning_of_week}'
    AND '#{end_of_week}' AND tipecust = 'RETAIL' AND bonus = '-' AND 
    kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') AND jenisbrgdisc = '#{brand}' GROUP BY customer")
  end
  ########## END CUSTOMER

  ########## CHANNEL
  def self.monthly_channel(branch, brand)
    self.find_by_sql("SELECT SUM(jumlah) AS jumlah, tipecust FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    MONTH(tanggalsj) = '#{1.month.ago.month}' AND YEAR(tanggalsj) = '#{1.month.ago.year}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY tipecust")
  end

  def self.weekly_channel(branch, brand)
    beginning_of_week = 1.week.ago.to_date.beginning_of_week.to_date
    end_of_week = 1.week.ago.to_date.end_of_week.to_date
    self.find_by_sql("SELECT SUM(jumlah) AS jumlah, tipecust FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY tipecust")
  end
  ########## END CHANNEL

  ########## START WEEKLY
  def self.weekly_city_summary(branch, brand)
    last_week_start = 2.week.ago.to_date.beginning_of_week.to_date
    last_week_end = 2.week.ago.to_date.end_of_week.to_date
    this_week_start = 1.week.ago.to_date.beginning_of_week.to_date
    this_week_end = 1.week.ago.to_date.end_of_week.to_date
    self.find_by_sql("SELECT kota,
      SUM(CASE WHEN tanggalsj BETWEEN '#{last_week_start}' AND '#{last_week_end}' THEN jumlah END) AS qty_last_week,
      SUM(CASE WHEN tanggalsj BETWEEN '#{last_week_start}' AND '#{last_week_end}' THEN harganetto1 END) AS val_last_week,
      SUM(CASE WHEN tanggalsj BETWEEN '#{this_week_start}' AND '#{this_week_end}' THEN jumlah END) AS qty_this_week,
      SUM(CASE WHEN tanggalsj BETWEEN '#{this_week_start}' AND '#{this_week_end}' THEN harganetto1 END) AS val_this_week
      FROM tblaporancabang WHERE cabang_id = '#{branch}' AND tanggalsj BETWEEN '#{last_week_start}' AND '#{this_week_end}'
      AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY kota")
  end

  def self.weekly_product_summary(branch, brand)
    last_week_start = 2.week.ago.to_date.beginning_of_week.to_date
    last_week_end = 2.week.ago.to_date.end_of_week.to_date
    this_week_start = 1.week.ago.to_date.beginning_of_week.to_date
    this_week_end = 1.week.ago.to_date.end_of_week.to_date
    self.find_by_sql("SELECT kodejenis,
      SUM(CASE WHEN tanggalsj BETWEEN '#{last_week_start}' AND '#{last_week_end}' THEN jumlah END) AS qty_last_week,
      SUM(CASE WHEN tanggalsj BETWEEN '#{last_week_start}' AND '#{last_week_end}' THEN harganetto1 END) AS val_last_week,
      SUM(CASE WHEN tanggalsj BETWEEN '#{this_week_start}' AND '#{this_week_end}' THEN jumlah END) AS qty_this_week,
      SUM(CASE WHEN tanggalsj BETWEEN '#{this_week_start}' AND '#{this_week_end}' THEN harganetto1 END) AS val_this_week
      FROM tblaporancabang WHERE cabang_id = '#{branch}' AND tanggalsj BETWEEN '#{last_week_start}' AND '#{this_week_end}'
      AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY kodejenis")
  end

  def self.weekly_summary(branch, brand)
    beginning_of_week = Date.today.beginning_of_week
    end_of_week = Date.today.end_of_week
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.a_week_ago(branch, brand)
    beginning_of_week = 1.week.ago.beginning_of_week.to_date
    end_of_week = 1.week.ago.end_of_week.to_date
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.two_weeks_ago(branch, brand)
    beginning_of_week = 2.week.ago.beginning_of_week.to_date
    end_of_week = 2.week.ago.end_of_week.to_date
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.three_weeks_ago(branch, brand)
    beginning_of_week = 3.week.ago.beginning_of_week.to_date
    end_of_week = 3.week.ago.end_of_week.to_date
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.four_weeks_ago(branch, brand)
    beginning_of_week = 4.week.ago.beginning_of_week.to_date
    end_of_week = 4.week.ago.end_of_week.to_date
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end
########## END WEEKLY
end