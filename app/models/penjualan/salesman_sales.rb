class Penjualan::SalesmanSales < ActiveRecord::Base
  self.table_name = "tblaporancabang"

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
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc = '#{sales.brand1}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY namaartikel, lebar
      ) as sub")
  end
  
  def self.last_month_customer(sales)
    self.find_by_sql("SELECT customer, kodejenis, km, dv, hb, sa, sb, total_1, total_2,
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
      AND '#{1.month.ago.to_date.end_of_month}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}'
      AND '#{2.month.ago.to_date.end_of_month}' THEN harganetto1 END) total_2    
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}' 
      AND '#{1.month.ago.to_date.end_of_month}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc = '#{sales.brand1}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY customer
      ) as sub")
  end
  
  def self.last_month_city(sales)
    self.find_by_sql("SELECT kota, kodejenis, km, dv, hb, sa, sb, total_1, total_2,
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
      AND '#{1.month.ago.to_date.end_of_month}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}'
      AND '#{2.month.ago.to_date.end_of_month}' THEN harganetto1 END) total_2    
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{2.month.ago.to_date.beginning_of_month}' 
      AND '#{1.month.ago.to_date.end_of_month}'
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc = '#{sales.brand1}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
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
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc = '#{sales.brand1}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
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
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
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
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
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
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
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
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY kodejenis WITH ROLLUP
      ) as sub")
  end
  
  ####################################
  
  def self.sales_daily_product(sales)
    self.find_by_sql("SELECT COALESCE(lc.kodejenis, 'Total') as kodejenis, lc.qty_1, lc.qty_2, 
    lc.val_1, lc.val_2, ROUND(((lc.qty_1/ROUND((st.target/24), 0)) * 100), 0) AS target FROM
      (
        SELECT kodejenis,
        SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
        SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1,
        SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
        SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2
        FROM tblaporancabang AS lc
        WHERE tanggalsj BETWEEN '#{2.day.ago.to_date}' 
        AND '#{1.day.ago.to_date}' AND nopo = '#{sales.address_number}' AND jenisbrgdisc = '#{sales.brand1}' AND
        tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
        GROUP BY kodejenis WITH ROLLUP
      ) AS lc
      LEFT JOIN sales_targets AS st
      ON lc.kodejenis = st.product AND st.user_id = '#{sales.id}'
      ")
  end

  def self.this_month_article(sales)
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
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc = '#{sales.brand1}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY namaartikel, lebar
      ) as sub")
  end
  
  def self.this_month_customer(sales)
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
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc = '#{sales.brand1}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY customer
      ) as sub")
  end
  
  def self.this_month_city(sales)
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
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc = '#{sales.brand1}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY kota
      ) as sub")
  end
  
  def self.this_week(sales)
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
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc = '#{sales.brand1}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY kodejenis WITH ROLLUP
      ) as sub")
  end

  def self.this_month(sales)
    self.find_by_sql("SELECT lc.kodejenis, lc.qty_1, lc.qty_2, lc.val_1, lc.val_2, 
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND(((lc.qty_1/st.target) * 100.0), 0) AS target,
    (st.target-lc.qty_1) AS rot FROM
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
      AND nopo = '#{sales.address_number}' AND jenisbrgdisc = '#{sales.brand1}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY kodejenis
      ) as lc
      LEFT JOIN sales_targets AS st
      ON lc.kodejenis = st.product AND st.user_id = '#{sales.id}'")
  end
end