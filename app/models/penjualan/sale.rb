class Penjualan::Sale < ActiveRecord::Base
  self.table_name = "tblaporancabang"
  ########## START MONTHLY
  def self.channel_nasional_this_month(date)
    self.find_by_sql("SELECT cc.channel, ly.val_elite, ly.val_classic, ly.val_serenity,
    ly.val_royal, ly.val_lady,
    ROUND((((ly.val_elite - ly.elite) / ly.elite) * 100), 0) AS elite,
    ROUND((((ly.val_lady - ly.lady) / ly.lady) * 100), 0) AS lady,
    ROUND((((ly.val_royal - ly.royal) / ly.royal) * 100), 0) AS royal,
    ROUND((((ly.val_serenity - ly.serenity) / ly.serenity) * 100), 0) AS serenity,
    ROUND((((ly.val_classic - ly.classic) / ly.classic) * 100), 0) AS classic FROM
    (
      SELECT channel FROM channel_customers
    ) as cc
    LEFT JOIN
      (
        SELECT jenisbrgdisc, tipecust,
        SUM(CASE WHEN fiscal_month = '#{date.month}' AND jenisbrgdisc = 'ELITE' THEN harganetto1 END) val_elite,
        SUM(CASE WHEN fiscal_month = '#{date.month}' AND jenisbrgdisc = 'LADY' THEN harganetto1 END) val_lady,
        SUM(CASE WHEN fiscal_month = '#{date.month}' AND jenisbrgdisc = 'ROYAL' THEN harganetto1 END) val_royal,
        SUM(CASE WHEN fiscal_month = '#{date.month}' AND jenisbrgdisc = 'SERENITY' THEN harganetto1 END) val_serenity,
        SUM(CASE WHEN fiscal_month = '#{date.month}' AND jenisbrgdisc = 'CLASSIC' THEN harganetto1 END) val_classic,
        SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
          '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}'
          AND jenisbrgdisc = 'ELITE' THEN harganetto1 END) elite,
        SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
          '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}'
          AND jenisbrgdisc = 'LADY' THEN harganetto1 END) lady,
        SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
          '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}'
          AND jenisbrgdisc = 'ROYAL' THEN harganetto1 END) royal,
        SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
          '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}'
          AND jenisbrgdisc = 'SERENITY' THEN harganetto1 END) serenity,
        SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
          '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}'
          AND jenisbrgdisc = 'CLASSIC' THEN harganetto1 END) classic
        FROM tblaporancabang WHERE fiscal_month BETWEEN '#{date.beginning_of_year.to_date.month}'
        AND '#{date.month}' AND fiscal_year BETWEEN '#{date.last_month.year}'
        AND '#{date.year}' AND bonus = '-' AND
        kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
        GROUP BY tipecust
      ) AS ly ON cc.channel = ly.tipecust
    ")
  end

  def self.retail_recap_brand(date, branch)
    self.find_by_sql("SELECT lc.jenisbrgdisc as brand, lc.val_1, lc.qty,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.v_last_year) / ly.v_last_year) * 100), 0) AS y_percentage,
    target_val, year_target,
    ROUND(((lc.y_val / st.year_target) * 100), 0) AS ty_percentage,
    ROUND(((lc.val_1 / st.target_val) * 100), 0) AS t_percentage FROM
    (
      SELECT area_id, jenisbrgdisc,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND
        fiscal_year = '#{date.year}' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') THEN harganetto1 END) y_val,
      SUM(CASE WHEN fiscal_month = '#{date.month}'
        AND fiscal_year = '#{date.year}' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') THEN jumlah END) qty,
      SUM(CASE WHEN fiscal_month = '#{date.month}'
        AND fiscal_year = '#{date.year}' AND
        kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') THEN harganetto1 END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}'
        AND fiscal_year = '#{date.last_month.year}' AND
        kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{date.last_month.month}'
      AND '#{date.month}' AND fiscal_year BETWEEN '#{date.last_month.year}'
      AND '#{date.year}' AND area_id NOT IN (1,50)
      AND area_id = '#{branch}' AND jenisbrgdisc != '' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
      GROUP BY jenisbrgdisc, area_id
    ) as lc
      LEFT JOIN
      (
        SELECT SUM(harganetto1) AS v_last_year, area_id, jenisbrgdisc FROM tblaporancabang WHERE
        fiscal_month = '#{Date.yesterday.last_year.month}' AND
        fiscal_year = '#{Date.yesterday.last_year.year}'
        AND area_id != 1 AND area_id = '#{branch}' AND
        tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
        AND jenisbrgdisc IS NOT NULL
        GROUP BY jenisbrgdisc, area_id
      ) AS ly ON lc.area_id = '#{branch}' AND lc.jenisbrgdisc = ly.jenisbrgdisc
      LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{date.month}' AND year = '#{date.year}'
          THEN target END) target_val,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' THEN target END) year_target
        FROM sales_target_values WHERE
        branch = '#{branch}'
        AND month BETWEEN '#{date.beginning_of_year.month}' AND
        '#{date.end_of_year.month}'
        AND (year = '#{date.year}' OR year IS NULL) GROUP BY branch, brand
      ) AS st ON lc.area_id = st.branch AND lc.jenisbrgdisc = st.brand
    ")
  end

  def self.retail_nasional_this_month_products(date, brand)
    self.find_by_sql("SELECT lc.kodejenis, lc.namaartikel, lc.jabar, lc.jakarta, lc.jakarta, lc.bali, lc.medan,
    lc.jatim, lc.semarang, lc.cirebon, lc.yogya, lc.palembang, lc.lampung, lc.makasar, lc.pekanbaru  FROM
    (
      SELECT kodeartikel, namaartikel, kodejenis,
      SUM(CASE WHEN area_id = 2 THEN jumlah END) jabar,
      SUM(CASE WHEN area_id = 3 THEN jumlah END) jakarta,
      SUM(CASE WHEN area_id = 4 THEN jumlah END) bali,
      SUM(CASE WHEN area_id = 5 THEN jumlah END) medan,
      SUM(CASE WHEN area_id = 7 THEN jumlah END) jatim,
      SUM(CASE WHEN area_id = 8 THEN jumlah END) semarang,
      SUM(CASE WHEN area_id = 9 THEN jumlah END) cirebon,
      SUM(CASE WHEN area_id = 10 THEN jumlah END) yogya,
      SUM(CASE WHEN area_id = 11 THEN jumlah END) palembang,
      SUM(CASE WHEN area_id = 13 THEN jumlah END) lampung,
      SUM(CASE WHEN area_id = 19 THEN jumlah END) makasar,
      SUM(CASE WHEN area_id = 20 THEN jumlah END) pekanbaru
      FROM tblaporancabang WHERE fiscal_month = '#{date.month}' AND
      fiscal_year = '#{date.year}' AND jenisbrgdisc = '#{brand}' AND
      area_id NOT IN (1,50) AND tipecust = 'RETAIL' AND bonus = '-' AND
      area_id IS NOT NULL
      GROUP BY namaartikel
    ) as lc
    LEFT JOIN
      (
        SELECT kodeartikel FROM tblaporancabang WHERE
        tanggalsj = '#{date.month}'
        AND jenisbrgdisc = '#{brand}' AND area_id NOT IN (1,50) AND
        tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
        AND area_id IS NOT NULL GROUP BY kodeartikel
      ) AS ly ON lc.kodeartikel = ly.kodeartikel
    ")
  end

  def self.retail_nasional_monthly_total(brand)
    self.find_by_sql("SELECT lc.val_1, lc.val_2, ly.revenue, st.month_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val1_1 / st.month_target) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / st.year_target) * 100), 0) AS ty_percentage FROM
    (
      SELECT jenisbrgdisc,
      SUM(CASE WHEN fiscal_month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}' AND
        '#{Date.yesterday.month}' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') THEN harganetto1 END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN jumlah END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND
        kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') THEN harganetto1 END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{2.month.ago.month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{Date.yesterday.last_month.beginning_of_year.to_date.month}'
      AND '#{Date.yesterday.last_month.month}' AND fiscal_year BETWEEN '#{Date.yesterday.last_month.beginning_of_year.to_date.year}'
      AND '#{Date.yesterday.last_month.year}' AND jenisbrgdisc = '#{brand}' AND area_id != 1 AND area_id != 50 AND
      tipecust = 'RETAIL' AND bonus = '-' AND area_id IS NOT NULL AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
      GROUP BY jenisbrgdisc
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(harganetto1) AS revenue, jenisbrgdisc FROM tblaporancabang WHERE
        fiscal_month = '#{Date.yesterday.last_month.last_year.month}' AND
        fiscal_year = '#{Date.yesterday.last_month.last_year.year}'
        AND jenisbrgdisc = '#{brand}' AND area_id != 1 AND
        tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
        AND area_id IS NOT NULL GROUP BY jenisbrgdisc
      ) AS ly ON lc.jenisbrgdisc = ly.jenisbrgdisc
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{Date.yesterday.last_month.month}' THEN target END) month_target,
        SUM(CASE WHEN month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}' AND
        '#{Date.yesterday.last_month.end_of_year.month}' THEN target END) year_target
        FROM sales_target_values WHERE
        brand = '#{brand}' AND
        month BETWEEN '#{Date.yesterday.last_month.beginning_of_year.month}' AND
        '#{Date.yesterday.last_month.end_of_year.month}'
        AND year BETWEEN '#{Date.yesterday.last_month.beginning_of_year.year}' AND
        '#{Date.yesterday.last_month.end_of_year.year}' GROUP BY brand
      ) AS st ON lc.jenisbrgdisc = st.brand
    ")
  end

  def self.retail_nasional_this_month_total(date, brand)
    self.find_by_sql("SELECT lc.val_1, lc.val_2, ly.revenue, st.month_target, st.year_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val1_1 / st.month_target) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / st.year_target) * 100), 0) AS ty_percentage FROM
    (
      SELECT jenisbrgdisc,
      SUM(CASE WHEN fiscal_month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.month}' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') THEN harganetto1 END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN jumlah END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN harganetto1 END) val1_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
        '#{date.last_month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{date.beginning_of_year.to_date.month}'
      AND '#{date.month}' AND fiscal_year BETWEEN '#{date.beginning_of_year.to_date.year}'
      AND '#{date.year}' AND jenisbrgdisc = '#{brand}' AND area_id != 1 AND area_id != 50 AND
      tipecust = 'RETAIL' AND bonus = '-' AND area_id IS NOT NULL AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
      GROUP BY jenisbrgdisc
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(harganetto1) AS revenue, jenisbrgdisc FROM tblaporancabang WHERE
        tanggalsj BETWEEN '#{date.last_year.beginning_of_month}' AND
        '#{date.month == Date.yesterday.last_year.month ? date.last_year : date.last_year.end_of_month}'
        AND jenisbrgdisc = '#{brand}' AND area_id != 1 AND
        tipecust = 'RETAIL' AND bonus = '-'
        AND area_id IS NOT NULL AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') GROUP BY jenisbrgdisc
      ) AS ly ON lc.jenisbrgdisc = ly.jenisbrgdisc
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{date.month}' THEN target END) month_target,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' THEN target END) year_target
        FROM sales_target_values WHERE
        brand = '#{brand}' AND
        month BETWEEN '#{Date.yesterday.beginning_of_year.month}' AND
        '#{Date.yesterday.end_of_year.month}'
        AND year BETWEEN '#{Date.yesterday.beginning_of_year.year}' AND
        '#{Date.yesterday.end_of_year.year}' GROUP BY brand
      ) AS st ON lc.jenisbrgdisc = st.brand
    ")
  end

  def self.retail_nasional_this_month_branches(date, brand)
    self.find_by_sql("SELECT st.area AS cabang, lc.val_1, lc.val_2, ly.revenue, st.month_target, st.year_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val1_1 / st.month_target) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / st.year_target) * 100), 0) AS ty_percentage FROM
    (
      SELECT area_id, jenisbrgdisc,
      SUM(CASE WHEN fiscal_month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.month}' THEN harganetto1 END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') THEN jumlah END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN harganetto1 END) val1_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
        '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}'
        THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{date.beginning_of_year.to_date.month}'
      AND '#{date.month}' AND fiscal_year BETWEEN '#{date.last_month.year}'
      AND '#{date.year}' AND jenisbrgdisc = '#{brand}' AND area_id != 1 AND area_id != 50 AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
      AND area_id IS NOT NULL GROUP BY jenisbrgdisc, area_id
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(harganetto1) AS revenue, area_id FROM tblaporancabang WHERE
        tanggalsj BETWEEN '#{date.last_year.beginning_of_month}' AND
        '#{date.month == Date.yesterday.last_year.month ? date.last_year : date.last_year.end_of_month}'
        AND jenisbrgdisc = '#{brand}' AND area_id NOT IN (1,50) AND
        tipecust = 'RETAIL' AND bonus = '-'
        AND area_id IS NOT NULL AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
        GROUP BY jenisbrgdisc, area_id
      ) AS ly ON lc.area_id = ly.area_id
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{date.month}' THEN target END) month_target,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' THEN target END) year_target
        FROM sales_target_values WHERE
        brand = '#{brand}' AND
        month BETWEEN '#{date.beginning_of_year.month}' AND
        '#{date.end_of_year.month}'
        AND year BETWEEN '#{date.beginning_of_year.year}' AND
        '#{date.end_of_year.year}' GROUP BY branch
      ) AS st ON lc.area_id = st.branch
    LEFT JOIN areas AS st
      ON lc.area_id = st.id
    ")
  end

  def self.retail_nasional_this_month_branch(date, brand)
    self.find_by_sql("SELECT lc.harga, cb.area AS branch FROM (
    SELECT SUM(harganetto1) AS harga, area_id FROM tblaporancabang
    WHERE fiscal_month = '#{date.month}'
    AND fiscal_year = '#{date.year}'
    AND tipecust = 'RETAIL' AND jenisbrgdisc = '#{brand}' AND bonus = '-'
    AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
    AND area_id NOT IN (1,50) AND area_id IS NOT NULL
    GROUP BY area_id) AS lc
    LEFT JOIN areas AS cb ON lc.area_id = cb.id
    ")
  end

  def self.target_retail_nasional_this_month(brand)
    self.find_by_sql("SELECT SUM(target) AS jumlah, month FROM sales_targets
    WHERE branch = '#{branch}' AND month BETWEEN '#{1.month.ago.beginning_of_year.month}'
    AND '#{Date.yesterday.month}' AND year = '#{1.month.ago.beginning_of_year.year}'
    AND brand = '#{brand}' AND area_id IS NOT NULL
    GROUP BY month, branch")
  end

  def self.retail_nasional_this_month(brand)
    self.find_by_sql("SELECT SUM(harganetto1) AS harga, fiscal_month FROM tblaporancabang
    WHERE fiscal_month BETWEEN '#{date.beginning_of_year.month}'
    AND '#{date.month}' AND fiscal_year = '#{date.beginning_of_year.year}'
    AND tipecust = 'RETAIL' AND jenisbrgdisc = '#{brand}' AND bonus = '-' AND area_id IS NOT NULL
    AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
    GROUP BY fiscal_month")
  end

  def self.retail_nasional_monthly_branches(brand)
    self.find_by_sql("SELECT st.area as cabang, lc.val_1, lc.val_2, ly.revenue, st.month_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val1_1 / st.month_target) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / st.year_target) * 100), 0) AS ty_percentage FROM
    (
      SELECT area_id, jenisbrgdisc,
      SUM(CASE WHEN fiscal_month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}' AND
        '#{Date.yesterday.last_month.month}' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') THEN harganetto1 END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN jumlah END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' AND
        kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') THEN harganetto1 END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.last_month.month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}'
      AND '#{Date.yesterday.last_month.month}' AND fiscal_year BETWEEN '#{Date.yesterday.last_month.last_month.year}'
      AND '#{Date.yesterday.last_month.year}' AND jenisbrgdisc = '#{brand}' AND area_id != 1 AND area_id != 50 AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') AND area_id IS NOT NULL
      GROUP BY jenisbrgdisc, area_id
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(harganetto1) AS revenue, area_id FROM tblaporancabang WHERE
        fiscal_month = '#{Date.yesterday.last_month.last_year.month}' AND fiscal_year = '#{Date.yesterday.last_month.last_year.year}'
        AND jenisbrgdisc = '#{brand}' AND area_id != 1 AND
        tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') AND area_id IS NOT NULL
        GROUP BY jenisbrgdisc, area_id
      ) AS ly ON lc.area_id = ly.area_id
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{Date.yesterday.last_month.month}' THEN target END) month_target,
        SUM(CASE WHEN month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}' AND
        '#{Date.yesterday.end_of_year.month}' THEN target END) year_target
        FROM sales_target_values WHERE
        brand = '#{brand}' AND
        month BETWEEN '#{Date.yesterday.beginning_of_year.month}' AND
        '#{Date.yesterday.end_of_year.month}'
        AND year BETWEEN '#{Date.yesterday.beginning_of_year.year}' AND
        '#{Date.yesterday.end_of_year.year}' GROUP BY branch
      ) AS st ON lc.area_id = st.branch
    LEFT JOIN areas AS st
      ON lc.area_id = st.id
    ")
  end

  def self.retail_nasional_monthly_branch(brand)
    self.find_by_sql("SELECT lc.harga, cb.area AS branch FROM (
    SELECT SUM(harganetto1) AS harga, area_id FROM tblaporancabang
    WHERE fiscal_month = '#{Date.yesterday.last_month.month}'
    AND fiscal_year = '#{Date.yesterday.last_month.year}'
    AND tipecust = 'RETAIL' AND jenisbrgdisc = '#{brand}' AND bonus = '-'
    AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
    AND area_id NOT IN (1,50) AND area_id IS NOT NULL
    GROUP BY area_id) AS lc
    LEFT JOIN areas AS cb ON lc.area_id = cb.id
    ")
  end

  def self.target_retail_nasional_monthly(brand)
    self.find_by_sql("SELECT SUM(target) AS jumlah, month FROM sales_targets
    WHERE branch = '#{branch}' AND month BETWEEN '#{1.month.ago.beginning_of_year.month}'
    AND '#{Date.yesterday.last_month.month}' AND year = '#{1.month.ago.beginning_of_year.year}'
    AND brand = '#{brand}'
    GROUP BY month, branch")
  end

  def self.retail_nasional_monthly(brand)
    self.find_by_sql("SELECT SUM(harganetto1) AS harga, fiscal_month FROM tblaporancabang
    WHERE fiscal_month BETWEEN '#{1.month.ago.beginning_of_year.month}'
    AND '#{Date.yesterday.last_month.month}' AND fiscal_year = '#{1.month.ago.beginning_of_year.year}'
    AND tipecust = 'RETAIL' AND jenisbrgdisc = '#{brand}' AND bonus = '-'
    AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
    GROUP BY fiscal_month")
  end

  def self.sales_through(branch, brand)

  end

  def self.on_time_delivery(date, branch, brand)
    self.find_by_sql("SELECT ((variance1/total_so) * 100) AS ontime, ((variance2/total_so) * 100) AS late,
    ((variance3/total_so) * 100) AS superlate, total_so FROM
    (
      SELECT diskon5,
      COUNT(CASE WHEN fiscal_month = '#{date.month}' AND
      diskon5 <= 3 THEN diskon5 END) variance1,
      COUNT(CASE WHEN fiscal_month = '#{date.month}' AND diskon5 BETWEEN 4 AND 7 THEN diskon5 END) variance2,
      COUNT(CASE WHEN fiscal_month = '#{date.month}' AND diskon5 > 7 THEN diskon5 END) variance3,
      COUNT(CASE WHEN fiscal_month = '#{date.month}' THEN diskon5 END) total_so
      FROM tblaporancabang WHERE fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}'
      AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB')
      ) as sub")
  end

  def self.monthly_article_summary(date, branch, brand)
    self.find_by_sql("SELECT namaartikel, lebar, qty_1, qty_2, val_1, val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT namaartikel, lebar,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN jumlah END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
        '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
        '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{date.last_month.month}'
      AND '#{date.month}' AND fiscal_year BETWEEN '#{date.last_month.year}'
      AND '#{date.year}' AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'KB')
      GROUP BY namaartikel, lebar
      ) as sub")
  end

  def self.monthly_salesman_summary(date, branch, brand)
    self.find_by_sql("SELECT lc.salesman, lc.qty_1, lc.qty_2, lc.val_1, lc.val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage,
    ROUND(((lc.qty_1/SUM(st.target)) * 100.0), 0) AS target FROM
    (
      SELECT area_id, salesman, nopo,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN jumlah END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
        '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
        '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{date.last_month.month}'
      AND '#{date.month}' AND fiscal_year BETWEEN '#{date.last_month.year}'
      AND '#{date.year}' AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')  AND nopo != '-'
      GROUP BY nopo
      ) as lc
      LEFT JOIN sales_targets st
      ON (st.address_number = lc.nopo) AND st.brand = '#{brand}'
      AND st.month = '#{date.month}' AND st.year = '#{date.year}'
      GROUP BY lc.nopo
      ")
  end

  def self.monthly_city_summary(date, branch, brand)
    self.find_by_sql("SELECT kota, kodejenis, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT kota, kodejenis,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND kodejenis = 'KM' THEN jumlah END) km,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND kodejenis = 'HB' THEN jumlah END) hb,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND kodejenis = 'DV' THEN jumlah END) dv,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND kodejenis = 'SA' THEN jumlah END) sa,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND kodejenis = 'SB' THEN jumlah END) sb,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND kodejenis = 'KB' THEN jumlah END) kb,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
        '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}' THEN harganetto1 END) total_2
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{date.last_month.month}'
      AND '#{date.month}' AND fiscal_year BETWEEN '#{date.last_month.year}'
      AND '#{date.year}' AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB')
      GROUP BY kota
      ) as sub")
  end

  def self.monthly_customer_summary(date, branch, brand)
    self.find_by_sql("SELECT customer, kodejenis, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT customer, kodejenis,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND kodejenis = 'KM' THEN jumlah END) km,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND kodejenis = 'HB' THEN jumlah END) hb,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND kodejenis = 'DV' THEN jumlah END) dv,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND kodejenis = 'SA' THEN jumlah END) sa,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND kodejenis = 'SB' THEN jumlah END) sb,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND kodejenis = 'KB' THEN jumlah END) kb,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN harganetto1 END) total_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
        '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}' THEN harganetto1 END) total_2
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{date.last_month.month}'
      AND '#{date.month}' AND fiscal_year BETWEEN '#{date.last_month.year}'
      AND '#{date.year}' AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB')
      GROUP BY customer
      ) as sub")
  end

  def self.revenue_last_month(date, branch, brand)
    self.find_by_sql("SELECT lc.val_1, lc.val_2, ly.revenue, st.month_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val_1 / SUM(st.month_target)) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / SUM(st.year_target)) * 100), 0) AS ty_percentage FROM
    (
      SELECT area_id,
      SUM(CASE WHEN fiscal_month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.last_month.month}'  AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB') THEN harganetto1 END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN jumlah END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
        '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{date.beginning_of_year.to_date.month}'
      AND '#{date.month}' AND fiscal_year BETWEEN '#{date.last_month.year}'
      AND '#{date.year}' AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
      GROUP BY jenisbrgdisc
    ) as lc
      LEFT JOIN
      (
        SELECT SUM(harganetto1) AS revenue, area_id FROM tblaporancabang WHERE
        tanggalsj BETWEEN '#{date.last_year.beginning_of_month}' AND
        '#{date.month == Date.yesterday.last_year.month ? date.last_year : date.last_year.end_of_month}'
        AND jenisbrgdisc = '#{brand}' AND area_id = '#{branch}' AND
        tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
        GROUP BY jenisbrgdisc
      ) AS ly ON lc.area_id = '#{branch}'
      LEFT JOIN
      (
        SELECT branch,
        SUM(CASE WHEN month = '#{date.month}' THEN target END) month_target,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' THEN target END) year_target
        FROM sales_target_values WHERE
        branch = '#{branch}' AND
        (brand = '#{brand}' OR brand IS NULL)
        AND month BETWEEN '#{date.beginning_of_year.month}' AND
        '#{date.end_of_year.month}'
        AND (year = '#{Date.yesterday.year}' OR year IS NULL)
      ) AS st ON lc.area_id = st.branch
    ")
  end

  def self.target_monthly_summaries(branch, brand)
    self.find_by_sql("SELECT SUM(target) AS jumlah, month FROM sales_targets
    WHERE branch = '#{branch}' AND month BETWEEN '#{1.month.ago.beginning_of_year.month}'
    AND '#{Date.yesterday.last_month.month}' AND year = '#{1.month.ago.beginning_of_year.year}'
    AND brand = '#{brand}'
    GROUP BY month, branch")
  end

  def self.monthly_summaries(branch, brand)
    self.find_by_sql("SELECT SUM(jumlah) AS jumlah, fiscal_month FROM tblaporancabang
    WHERE area_id = '#{branch}' AND fiscal_month BETWEEN '#{1.month.ago.beginning_of_year.month}'
    AND '#{Date.yesterday.last_month.month}' AND fiscal_year = '#{1.month.ago.beginning_of_year.year}'
    AND tipecust = 'RETAIL' AND jenisbrgdisc = '#{brand}' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
    GROUP BY fiscal_month, area_id")
  end

  def self.monthly_product_summary(date, branch, brand)
    self.find_by_sql("SELECT lc.kodejenis, lc.qty_1, lc.qty_2, lc.val_1, lc.val_2,
    ROUND((((lc.val_1 - lc.val_2) /lc. val_2) * 100), 0) AS percentage,
    ROUND(((lc.qty_1/SUM(st.target)) * 100.0), 0) AS target FROM
    (
      SELECT kodejenis,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN jumlah END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
        '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
        '#{date.month == Date.yesterday.month ? date.last_month : date.last_month.end_of_month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE fiscal_month BETWEEN '#{date.last_month.month}'
      AND '#{date.month}' AND fiscal_year BETWEEN '#{date.last_month.year}'
      AND '#{date.year}' AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB')
      GROUP BY kodejenis
      ) as lc
      LEFT JOIN sales_targets AS st
      ON lc.kodejenis = st.product AND (st.brand = '#{brand}' OR st.brand IS NULL) AND
      (st.branch = '#{branch}' OR st.branch IS NULL)
      AND (st.month = '#{date.month}' OR st.month IS NULL)
      AND (st.year = '#{date.year}' OR st.year IS NULL) GROUP BY st.product
      ")
  end

  def self.monthly_summary(branch, brand)
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND
    MONTH(tanggalsj) = '#{Date.today.month}' AND YEAR(tanggalsj) = '#{Date.today.year}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end
  ########## END MONTHLY

  ########## MOST ITEMS
  def self.most_items_ordered_weekly(branch, brand)
    self.find_by_sql("SELECT lc.namaartikel AS article, lc.qty_4, lc.val_4, lc.qty_3, lc.val_3,
    lc.qty_2, lc.val_2, lc.qty_1, lc.val_1 FROM
    (
      SELECT namaartikel,
      SUM(CASE WHEN tanggalsj BETWEEN '#{4.weeks.ago.beginning_of_week.to_date}' AND '#{4.weeks.ago.end_of_week.to_date}' THEN jumlah END) qty_4,
      SUM(CASE WHEN tanggalsj BETWEEN '#{4.weeks.ago.beginning_of_week.to_date}' AND '#{4.weeks.ago.end_of_week.to_date}' THEN harganetto1 END) val_4,
      SUM(CASE WHEN tanggalsj BETWEEN '#{3.weeks.ago.beginning_of_week.to_date}' AND '#{3.weeks.ago.end_of_week.to_date}' THEN jumlah END) qty_3,
      SUM(CASE WHEN tanggalsj BETWEEN '#{3.weeks.ago.beginning_of_week.to_date}' AND '#{3.weeks.ago.end_of_week.to_date}' THEN harganetto1 END) val_3,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.weeks.ago.beginning_of_week.to_date}' AND '#{2.weeks.ago.end_of_week.to_date}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.weeks.ago.beginning_of_week.to_date}' AND '#{2.weeks.ago.end_of_week.to_date}' THEN harganetto1 END) val_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.beginning_of_week.to_date}' AND '#{1.week.ago.end_of_week.to_date}' THEN jumlah END) qty_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.beginning_of_week.to_date}' AND '#{1.week.ago.end_of_week.to_date}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{4.weeks.ago.beginning_of_week.to_date}' AND '#{1.week.ago.end_of_week.to_date}' THEN jumlah END) most
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{4.weeks.ago.to_date}' AND
      '#{1.week.ago.end_of_week.to_date}' AND jenisbrgdisc = '#{brand}' AND area_id = '#{branch}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'KB')
      GROUP BY namaartikel ORDER BY most DESC LIMIT 10
      ) as lc")
  end

  def self.most_items_ordered_monthly(branch, brand)
    self.find_by_sql("SELECT namaartikel, ordered, lebar, value FROM (
    SELECT kodejenis, namaartikel, lebar, SUM(jumlah) AS ordered, SUM(harganetto1) AS value FROM tblaporancabang
    WHERE area_id = '#{branch}' AND MONTH(tanggalsj) = '#{1.month.ago.to_date.month}' AND
    YEAR(tanggalsj) = '#{1.month.ago.to_date.year}' AND tipecust = 'RETAIL' AND bonus = '-' AND
    kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') AND jenisbrgdisc = '#{brand}'
    GROUP BY namaartikel, lebar) totals ORDER BY ordered DESC LIMIT 10")
  end
  ########## END MOST ITEMS

  ########## CUSTOMER
  def self.customer_summary_monthly(branch, brand)
    self.find_by_sql("SELECT customer, salesman, SUM(jumlah) AS ordered, SUM(harganetto1) AS price,
    jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND MONTH(tanggalsj) = '#{1.month.ago.to_date.month}' AND
    YEAR(tanggalsj) = '#{1.month.ago.to_date.year}' AND tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') AND jenisbrgdisc = '#{brand}' GROUP BY customer")
  end

  def self.customer_summary(branch, brand)
    beginning_of_week = 1.week.ago.to_date.beginning_of_week.to_date
    end_of_week = 1.week.ago.to_date.end_of_week.to_date
    self.find_by_sql("SELECT customer, salesman, SUM(jumlah) AS ordered, SUM(harganetto1) AS price,
    jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND tanggalsj BETWEEN '#{beginning_of_week}'
    AND '#{end_of_week}' AND tipecust = 'RETAIL' AND bonus = '-' AND
    kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') AND jenisbrgdisc = '#{brand}' GROUP BY customer")
  end
  ########## END CUSTOMER

  ########## CHANNEL
  def self.monthly_channel(branch, brand)
    self.find_by_sql("SELECT SUM(jumlah) AS jumlah, tipecust FROM tblaporancabang WHERE area_id = '#{branch}' AND
    MONTH(tanggalsj) = '#{1.month.ago.month}' AND YEAR(tanggalsj) = '#{1.month.ago.year}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY tipecust")
  end

  def self.weekly_channel(branch, brand)
    beginning_of_week = 1.week.ago.to_date.beginning_of_week.to_date
    end_of_week = 1.week.ago.to_date.end_of_week.to_date
    self.find_by_sql("SELECT SUM(jumlah) AS jumlah, tipecust FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY tipecust")
  end
  ########## END CHANNEL

  ########## START WEEKLY

  def self.retail_nasional_weekly(brand)
    self.find_by_sql("SELECT SUM(harganetto1) AS val, CONCAT('WEEK ', week) AS weekly_name FROM tblaporancabang
    WHERE week BETWEEN '#{5.weeks.ago.to_date.cweek}'
    AND '#{1.weeks.ago.to_date.cweek}' AND fiscal_year BETWEEN '#{5.weeks.ago.to_date.year}' AND '#{1.weeks.ago.to_date.year}'
    AND tipecust = 'RETAIL' AND jenisbrgdisc = '#{brand}' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB')
    GROUP BY week")
  end

  def self.retail_nasional_weekly_branch(brand)
    self.find_by_sql("SELECT st.Cabang AS cabang, lc.qty_4, lc.val_4, lc.qty_3, lc.val_3,
    lc.qty_2, lc.val_2, lc.qty_1, lc.val_1, ROUND((((val_3 - val_4)/val_4) * 100)) AS chg_3,
    ROUND((((val_2 - val_3)/val_3) * 100)) AS chg_2, ROUND((((val_1 - val_2)/val_2) * 100)) AS chg_1 FROM
    (
      SELECT area_id,
      SUM(CASE WHEN tanggalsj BETWEEN '#{4.weeks.ago.to_date}' AND '#{4.weeks.ago.end_of_week.to_date}' THEN jumlah END) qty_4,
      SUM(CASE WHEN tanggalsj BETWEEN '#{4.weeks.ago.to_date}' AND '#{4.weeks.ago.end_of_week.to_date}' THEN harganetto1 END) val_4,
      SUM(CASE WHEN tanggalsj BETWEEN '#{3.weeks.ago.to_date}' AND '#{3.weeks.ago.end_of_week.to_date}' THEN jumlah END) qty_3,
      SUM(CASE WHEN tanggalsj BETWEEN '#{3.weeks.ago.to_date}' AND '#{3.weeks.ago.end_of_week.to_date}' THEN harganetto1 END) val_3,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.weeks.ago.to_date}' AND '#{2.weeks.ago.end_of_week.to_date}' THEN jumlah END) qty_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{2.weeks.ago.to_date}' AND '#{2.weeks.ago.end_of_week.to_date}' THEN harganetto1 END) val_2,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date}' AND '#{1.week.ago.end_of_week.to_date}' THEN jumlah END) qty_1,
      SUM(CASE WHEN tanggalsj BETWEEN '#{1.week.ago.to_date}' AND '#{1.week.ago.end_of_week.to_date}' THEN harganetto1 END) val_1
      FROM tblaporancabang WHERE week BETWEEN '#{4.week.ago.to_date.cweek}'
      AND '#{1.week.ago.to_date.cweek}' AND fiscal_year BETWEEN '#{4.week.ago.year}'
      AND '#{1.week.ago.year}' AND jenisbrgdisc = '#{brand}' AND area_id != 1 AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB')
      GROUP BY area_id
      ) as lc
      LEFT JOIN tbidcabang AS st
      ON lc.area_id = st.id")
  end

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
      FROM tblaporancabang WHERE area_id = '#{branch}' AND tanggalsj BETWEEN '#{last_week_start}' AND '#{this_week_end}'
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
      FROM tblaporancabang WHERE area_id = '#{branch}' AND tanggalsj BETWEEN '#{last_week_start}' AND '#{this_week_end}'
      AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY kodejenis")
  end

  def self.weekly_summary(branch, brand)
    beginning_of_week = Date.today.beginning_of_week
    end_of_week = Date.today.end_of_week
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.a_week_ago(branch, brand)
    beginning_of_week = 1.week.ago.beginning_of_week.to_date
    end_of_week = 1.week.ago.end_of_week.to_date
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.two_weeks_ago(branch, brand)
    beginning_of_week = 2.week.ago.beginning_of_week.to_date
    end_of_week = 2.week.ago.end_of_week.to_date
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.three_weeks_ago(branch, brand)
    beginning_of_week = 3.week.ago.beginning_of_week.to_date
    end_of_week = 3.week.ago.end_of_week.to_date
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.four_weeks_ago(branch, brand)
    beginning_of_week = 4.week.ago.beginning_of_week.to_date
    end_of_week = 4.week.ago.end_of_week.to_date
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'KB') GROUP BY jenisbrgdisc")
  end
########## END WEEKLY
end