class Penjualan::Sale < ActiveRecord::Base
  self.table_name = "tblaporancabang"
  ########## START MONTHLY
  def self.monthly_city_summary(branch, brand)
    two_month = 2.month.ago.to_date
    last_month = 1.month.ago.to_date
    self.find_by_sql("SELECT kota,
      SUM(CASE WHEN MONTH(tanggalsj) = '#{two_month.month}' AND YEAR(tanggalsj) = '#{two_month.year}' THEN jumlah END) AS q_two,
      SUM(CASE WHEN MONTH(tanggalsj) = '#{two_month.month}' AND YEAR(tanggalsj) = '#{two_month.year}' THEN harganetto1 END) AS v_two,
      SUM(CASE WHEN MONTH(tanggalsj) = '#{last_month.month}' AND YEAR(tanggalsj) = '#{last_month.year}' THEN jumlah END) AS q_one,
      SUM(CASE WHEN MONTH(tanggalsj) = '#{last_month.month}' AND YEAR(tanggalsj) = '#{last_month.year}' THEN harganetto1 END) AS v_one
      FROM tblaporancabang WHERE cabang_id = '#{branch}' AND tanggalsj BETWEEN '#{two_month.beginning_of_month.to_date}' 
      AND tipecust = 'RETAIL' AND '#{last_month.end_of_month.to_date}' AND jenisbrgdisc = '#{brand}' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY kota")
  end
  
  def self.monthly_product_summary(branch, brand)
    two_month = 2.month.ago.to_date
    last_month = 1.month.ago.to_date
    self.find_by_sql("SELECT kodejenis,
      SUM(CASE WHEN MONTH(tanggalsj) = '#{two_month.month}' AND YEAR(tanggalsj) = '#{two_month.year}' THEN jumlah END) AS q_two,
      SUM(CASE WHEN MONTH(tanggalsj) = '#{two_month.month}' AND YEAR(tanggalsj) = '#{two_month.year}' THEN harganetto1 END) AS v_two,
      SUM(CASE WHEN MONTH(tanggalsj) = '#{last_month.month}' AND YEAR(tanggalsj) = '#{last_month.year}' THEN jumlah END) AS q_one,
      SUM(CASE WHEN MONTH(tanggalsj) = '#{last_month.month}' AND YEAR(tanggalsj) = '#{last_month.year}' THEN harganetto1 END) AS v_one
      FROM tblaporancabang WHERE cabang_id = '#{branch}' AND tanggalsj BETWEEN '#{two_month.beginning_of_month.to_date}' 
      AND tipecust = 'RETAIL' AND '#{last_month.end_of_month.to_date}' AND jenisbrgdisc = '#{brand}' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') 
      GROUP BY kodejenis")
  end

  def self.monthly_summary(branch, brand)
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    MONTH(tanggalsj) = '#{Date.today.month}' AND YEAR(tanggalsj) = '#{Date.today.year}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.a_month_ago(branch, brand)
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    MONTH(tanggalsj) = '#{1.month.ago.month}' AND YEAR(tanggalsj) = '#{1.month.ago.year}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.two_month_ago(branch, brand)
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    MONTH(tanggalsj) = '#{2.month.ago.month}' AND YEAR(tanggalsj) = '#{2.month.ago.year}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.three_month_ago(branch, brand)
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    MONTH(tanggalsj) = '#{3.month.ago.month}' AND YEAR(tanggalsj) = '#{3.month.ago.year}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.four_month_ago(branch, brand)
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE cabang_id = '#{branch}' AND
    MONTH(tanggalsj) = '#{4.month.ago.month}' AND YEAR(tanggalsj) = '#{4.month.ago.year}' AND jenisbrgdisc = '#{brand}' AND
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