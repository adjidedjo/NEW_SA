class Penjualan::SaleDaily < Penjualan::Sale
  self.table_name = "tblaporancabang"
  
  def self.sales_daily_product(branch, brand)
    self.find_by_sql("SELECT COALESCE(kodejenis, 'Total') as kodejenis,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{2.day.ago.to_date}' 
      AND '#{1.day.ago.to_date}' AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY kodejenis WITH ROLLUP")
  end

  def self.this_month_salesman(branch, brand)
    self.find_by_sql("SELECT salesman, qty_1, qty_2, val_1, val_2, 
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT salesman,
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
      AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY salesman
      ) as sub")
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
      AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY namaartikel, lebar
      ) as sub")
  end
  
  def self.this_month_customer(branch, brand)
    self.find_by_sql("SELECT customer, kodejenis, km, dv, hb, sa, sb, total_1, total_2,
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
      AND '#{Date.yesterday}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN harganetto1 END) total_2    
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}' 
      AND '#{Date.yesterday}'
      AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY customer
      ) as sub")
  end
  
  def self.this_month_city(branch, brand)
    self.find_by_sql("SELECT kota, kodejenis, km, dv, hb, sa, sb, total_1, total_2,
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
      AND '#{Date.yesterday}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}'
      AND '#{Date.yesterday.last_month}' THEN harganetto1 END) total_2    
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month}' 
      AND '#{Date.yesterday}'
      AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY kota
      ) as sub")
  end

  def self.this_month(branch, brand)
    self.find_by_sql("SELECT kodejenis, qty_1, qty_2, val_1, val_2, 
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
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
      AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY kodejenis
      ) as sub")
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
      AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY kodejenis WITH ROLLUP
      ) as sub")
  end
  
  def self.daily_summary(branch, brand)
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah 
    FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    tanggalsj BETWEEN '#{6.day.ago.to_date}' AND '#{1.day.ago.to_date}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY tanggalsj")
  end
  
  def self.daily_product(branch, brand)
    self.find_by_sql("SELECT kodejenis,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1
      FROM tblaporancabang WHERE cabang_id = '#{branch}' AND tanggalsj BETWEEN '#{2.day.ago.to_date}' AND '#{1.day.ago.to_date}'
      AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY kodejenis")
  end

  def self.daily_summary(branch, brand)
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    tanggalsj BETWEEN '#{6.day.ago.to_date}' AND '#{1.day.ago.to_date}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY tanggalsj")
  end
  
  def self.daily_salesman(branch, brand)
    self.find_by_sql("SELECT salesman,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1
      FROM tblaporancabang WHERE cabang_id = '#{branch}' AND tanggalsj BETWEEN '#{2.day.ago.to_date}' AND '#{1.day.ago.to_date}'
      AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY salesman")
  end
  
  def self.daily_customer(branch, brand)
    self.find_by_sql("SELECT kode_customer, customer, salesman,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN jumlah END) AS qty_2,
      SUM(CASE WHEN tanggalsj = '#{2.day.ago.to_date}' THEN harganetto1 END) AS val_2,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN jumlah END) AS qty_1,
      SUM(CASE WHEN tanggalsj = '#{1.day.ago.to_date}' THEN harganetto1 END) AS val_1
      FROM tblaporancabang WHERE cabang_id = '#{branch}' AND tanggalsj BETWEEN '#{2.day.ago.to_date}' AND '#{1.day.ago.to_date}'
      AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY kode_customer")
  end
end