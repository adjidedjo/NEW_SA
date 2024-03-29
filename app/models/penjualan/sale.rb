class Penjualan::Sale < ActiveRecord::Base
  self.table_name = "tblaporancabang"
  ########## START MONTHLY

  def self.retail_nasional_this_month_accessories(date, brand)
    self.find_by_sql("SELECT lc.kodejenis, lc.namaartikel, lc.jabar, lc.jakarta, lc.jakarta, lc.bali, lc.medan,
    lc.jatim, lc.semarang, lc.cirebon, lc.yogya, lc.palembang, lc.lampung, lc.makasar, lc.pekanbaru, lc.manado, lc.samarinda  FROM
    (
      SELECT article AS kodeartikel, article_desc AS namaartikel, product AS kodejenis,
      SUM(CASE WHEN branch = 2 THEN sales_amount END) jabar,
      SUM(CASE WHEN branch = 3 THEN sales_amount END) jakarta,
      SUM(CASE WHEN branch = 4 THEN sales_amount END) bali,
      SUM(CASE WHEN branch = 5 THEN sales_amount END) medan,
      SUM(CASE WHEN branch = 7 THEN sales_amount END) jatim,
      SUM(CASE WHEN branch = 8 THEN sales_amount END) semarang,
      SUM(CASE WHEN branch = 9 THEN sales_amount END) cirebon,
      SUM(CASE WHEN branch = 10 THEN sales_amount END) yogya,
      SUM(CASE WHEN branch = 11 THEN sales_amount END) palembang,
      SUM(CASE WHEN branch = 13 THEN sales_amount END) lampung,
      SUM(CASE WHEN branch = 19 THEN sales_amount END) makasar,
      SUM(CASE WHEN branch = 20 THEN sales_amount END) pekanbaru,
      SUM(CASE WHEN branch = 26 THEN sales_amount END) manado,
      SUM(CASE WHEN branch = 55 THEN sales_amount END) samarinda
      FROM sales_mart.RET1ARTICLE WHERE fiscal_month = '#{date.month}' AND
      fiscal_year = '#{date.year}' AND brand REGEXP '#{brand}' AND product NOT IN ('KM', 'DV','HB', 'SA', 'SB','ST') GROUP BY kodeartikel
    ) as lc
    ")
  end
  
  def self.export_sales_report(from, to, area)
    find_by_sql("
    SELECT ri.*, IFNULL((ri.harganetto2 + IFNULL(rm.harganetto2,0)),0) AS net FROM
    (
      SELECT s.tanggalsj, s.nosj_so, s.nofaktur, s.orty, s.noso, s.kode_customer, s.customer,
        s.salesman, s.alamat_so,
        s.kodebrg, s.namabrg, s.kodejenis, s.jenisbrgdisc, s.namaartikel, s.namakain, s.panjang, s.lebar,
        SUM(s.jumlah) jumlah, s.harganetto1,
        SUM(s.harganetto2) harganetto2, s.diskon1, s.diskon2, s.diskon3, s.diskon4, s.diskon5, s.diskonsum,
        s.diskonrp, s.cashback, s.nupgrade, s.kota, s.reference,
        s.customerpo_so, s.ketppb, s.tipecust
        FROM dbmarketing.tblaporancabang AS s
        WHERE s.tanggalsj BETWEEN '#{from.to_date}' AND '#{to.to_date}'
        AND s.area_id = '#{area}' AND orty IN ('RI', 'RO', 'RX') GROUP BY s.kodebrg, s.nofaktur, s.kode_customer, s.noso
        ORDER BY reference DESC
    ) ri
    LEFT JOIN
    (
      SELECT s.tanggalsj, s.nosj_so, s.nofaktur, s.orty, s.noso, s.kode_customer, s.customer,
        s.salesman, s.alamat_so,
        s.kodebrg, s.namabrg, s.kodejenis, s.jenisbrgdisc, s.namaartikel, s.namakain, s.panjang, s.lebar,
        SUM(s.jumlah) jumlah, s.harganetto1,
        SUM(s.harganetto2) harganetto2, s.diskon1, s.diskon2, s.diskon3, s.diskon4, s.diskon5, s.diskonsum,
        s.diskonrp, s.cashback, s.nupgrade, s.kota, s.reference,
        s.customerpo_so, s.ketppb, s.tipecust
        FROM dbmarketing.tblaporancabang AS s
        WHERE s.tanggalsj BETWEEN '#{from.to_date}' AND '#{to.to_date}'
        AND s.area_id = '#{area}' AND orty = ('RM') GROUP BY s.kodebrg, s.nofaktur, s.kode_customer, s.noso
        ORDER BY reference DESC
    ) rm ON rm.reference = ri.nofaktur AND rm.kodebrg = ri.kodebrg AND rm.kode_customer = ri.kode_customer
    ")
  end

  def self.channel_nasional_this_month(date)
    self.find_by_sql("SELECT cc.channel, ly.val_elite, ly.val_classic, ly.val_serenity,
    ly.val_royal, ly.val_lady, ly.val_tote,
    ROUND((((ly.val_elite - ly.elite) / ly.elite) * 100), 0) AS elite,
    ROUND((((ly.val_lady - ly.lady) / ly.lady) * 100), 0) AS lady,
    ROUND((((ly.val_royal - ly.royal) / ly.royal) * 100), 0) AS royal,
    ROUND((((ly.val_serenity - ly.serenity) / ly.serenity) * 100), 0) AS serenity,
    ROUND((((ly.val_classic - ly.classic) / ly.classic) * 100), 0) AS classic,
    ROUND((((ly.val_tote - ly.tote) / ly.tote) * 100), 0) AS tote FROM
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
        SUM(CASE WHEN fiscal_month = '#{date.month}' AND jenisbrgdisc = 'TOTE' THEN harganetto1 END) val_tote,
        SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
          '#{date.to_date - 1.month}'
          AND jenisbrgdisc = 'ELITE' THEN harganetto1 END) elite,
        SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
          '#{date.to_date - 1.month}'
          AND jenisbrgdisc = 'LADY' THEN harganetto1 END) lady,
        SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
          '#{date.to_date - 1.month}'
          AND jenisbrgdisc = 'ROYAL' THEN harganetto1 END) royal,
        SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
          '#{date.to_date - 1.month}'
          AND jenisbrgdisc = 'SERENITY' THEN harganetto1 END) serenity,
        SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
          '#{date.to_date - 1.month}'
          AND jenisbrgdisc = 'CLASSIC' THEN harganetto1 END) classic,
        SUM(CASE WHEN tanggalsj BETWEEN '#{date.last_month.beginning_of_month}' AND
          '#{date.to_date - 1.month}'
          AND jenisbrgdisc = 'TOTE' THEN harganetto1 END) tote
        FROM tblaporancabang WHERE tanggalsj BETWEEN '2022-08-01' and '2022-09-12'
        GROUP BY tipecust
      ) AS ly ON cc.channel = ly.tipecust
    ")
  end

  def self.retail_recap_brand(date, branch)
    self.find_by_sql("SELECT lc.brand as brand, lc.val_1, lc.qty,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.v_last_year) / ly.v_last_year) * 100), 0) AS y_percentage,
    target_val, year_target,
    ROUND(((lc.y_val / st.year_target) * 100), 0) AS ty_percentage,
    ROUND(((lc.val_1 / st.target_val) * 100), 0) AS t_percentage FROM
    (
      SELECT area, brand,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND
        fiscal_year = '#{date.year}'  THEN sales_amount END) y_val,
      SUM(CASE WHEN fiscal_month = '#{date.month}'
        AND fiscal_year = '#{date.year}' THEN sales_quantity END) qty,
      SUM(CASE WHEN fiscal_month = '#{date.month}'
        AND fiscal_year = '#{date.year}'  THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}'
        AND fiscal_year = '#{date.last_month.year}'  THEN sales_amount END) val_2
      FROM sales_mart.RET1BRAND WHERE fiscal_month IN ('#{date.last_month.month}','#{date.month}') AND fiscal_year BETWEEN '#{date.last_month.year}'
      AND '#{date.year}' AND branch NOT IN (1,50)
      AND branch = '#{branch}' AND brand != ''
      GROUP BY brand, area
    ) as lc
      LEFT JOIN
      (
        SELECT SUM(sales_amount) AS v_last_year, area, brand FROM sales_mart.RET1BRAND WHERE
        fiscal_month = '#{Date.yesterday.last_year.month}' AND
        fiscal_year = '#{Date.yesterday.last_year.year}'
      ) AS ly ON lc.area = ly.area AND lc.area = ly.area
      LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{date.month}' AND year = '#{date.year}'
          THEN amount END) target_val,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' THEN amount END) year_target
        FROM sales_target_values WHERE
        branch = '#{branch}'
        AND month BETWEEN '#{date.beginning_of_year.month}' AND
        '#{date.end_of_year.month}'
        AND (year = '#{date.year}' OR year IS NULL) GROUP BY branch, brand
      ) AS st ON lc.area = st.branch AND lc.brand REGEXP st.brand
    ")
  end

  def self.modern_nasional_this_month_products(date, brand)
    self.find_by_sql("SELECT lc.kodejenis, lc.namaartikel, lc.jabar, lc.jakarta, lc.jakarta, lc.bali,
    lc.jatim, lc.yogya, lc.semarang, lc.pusat  FROM
    (
      SELECT article AS kodeartikel, article_desc AS namaartikel, product AS kodejenis,
      SUM(CASE WHEN branch = 2 THEN sales_quantity END) jabar,
      SUM(CASE WHEN branch = 23 THEN sales_quantity END) jakarta,
      SUM(CASE WHEN branch = 4 THEN sales_quantity END) bali,
      SUM(CASE WHEN branch = 7 THEN sales_quantity END) jatim,
      SUM(CASE WHEN branch = 8 THEN sales_quantity END) semarang,
      SUM(CASE WHEN branch = 10 THEN sales_quantity END) yogya,
      SUM(CASE WHEN branch = 1 THEN sales_quantity END) pusat
      FROM sales_mart.MM1ARTICLE WHERE fiscal_month = '#{date.month}' AND
      fiscal_year = '#{date.year}' AND brand REGEXP '#{brand}' GROUP BY kodeartikel
    ) as lc
    ")
  end

  def self.direct_ecom_nasional_this_month_products(date, brand)
    self.find_by_sql("SELECT lc.kodejenis, lc.namaartikel, lc.jabar, lc.jakarta, lc.jakarta, lc.bali,
    lc.jatim  FROM
    (
      SELECT article AS kodeartikel, article_desc AS namaartikel, product AS kodejenis,
      SUM(CASE WHEN branch = 2 THEN sales_quantity END) jabar,
      SUM(CASE WHEN branch = 23 THEN sales_quantity END) jakarta,
      SUM(CASE WHEN branch = 4 THEN sales_quantity END) bali,
      SUM(CASE WHEN branch = 7 THEN sales_quantity END) jatim
      FROM sales_mart.EC1ARTICLE WHERE fiscal_month = '#{date.month}' AND
      fiscal_year = '#{date.year}' AND brand REGEXP '#{brand}' GROUP BY kodeartikel
    ) as lc
    ")
  end

  def self.direct_nasional_this_month_products(date, brand)
    self.find_by_sql("SELECT lc.kodejenis, lc.namaartikel, lc.jabar, lc.jakarta, lc.jakarta, lc.bali,
    lc.jatim  FROM
    (
      SELECT article AS kodeartikel, article_desc AS namaartikel, product AS kodejenis,
      SUM(CASE WHEN branch = 2 THEN sales_quantity END) jabar,
      SUM(CASE WHEN branch = 23 THEN sales_quantity END) jakarta,
      SUM(CASE WHEN branch = 4 THEN sales_quantity END) bali,
      SUM(CASE WHEN branch = 7 THEN sales_quantity END) jatim
      FROM sales_mart.SH1ARTICLE WHERE fiscal_month = '#{date.month}' AND
      fiscal_year = '#{date.year}' AND brand REGEXP '#{brand}' GROUP BY kodeartikel
    ) as lc
    ")
  end

  def self.retail_nasional_this_month_products(date, brand)
    self.find_by_sql("SELECT lc.kodejenis, lc.namaartikel, lc.jabar, lc.jakarta, lc.jakarta, lc.bali, lc.medan,
    lc.jatim, lc.semarang, lc.cirebon, lc.yogya, lc.palembang, lc.lampung, lc.makasar, lc.pekanbaru, lc.manado, lc.samarinda  FROM
    (
      SELECT article AS kodeartikel, article_desc AS namaartikel, product AS kodejenis,
      SUM(CASE WHEN branch = 2 THEN sales_quantity END) jabar,
      SUM(CASE WHEN branch = 3 THEN sales_quantity END) jakarta,
      SUM(CASE WHEN branch = 4 THEN sales_quantity END) bali,
      SUM(CASE WHEN branch = 5 THEN sales_quantity END) medan,
      SUM(CASE WHEN branch = 7 THEN sales_quantity END) jatim,
      SUM(CASE WHEN branch = 8 THEN sales_quantity END) semarang,
      SUM(CASE WHEN branch = 9 THEN sales_quantity END) cirebon,
      SUM(CASE WHEN branch = 10 THEN sales_quantity END) yogya,
      SUM(CASE WHEN branch = 11 THEN sales_quantity END) palembang,
      SUM(CASE WHEN branch = 13 THEN sales_quantity END) lampung,
      SUM(CASE WHEN branch = 19 THEN sales_quantity END) makasar,
      SUM(CASE WHEN branch = 20 THEN sales_quantity END) pekanbaru,
      SUM(CASE WHEN branch = 26 THEN sales_quantity END) manado,
      SUM(CASE WHEN branch = 55 THEN sales_quantity END) samarinda
      FROM sales_mart.RET1ARTICLE WHERE fiscal_month = '#{date.month}' AND
      fiscal_year = '#{date.year}' AND brand REGEXP '#{brand}' GROUP BY kodeartikel
    ) as lc
    ")
  end

  def self.retail_nasional_monthly_total(brand)
    self.find_by_sql("SELECT lc.val_1, lc.val_2, ly.revenue, st.month_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val1_1 / st.month_target) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / st.year_target) * 100), 0) AS ty_percentage FROM
    (
      SELECT brand AS jenisbrgdisc,
      SUM(CASE WHEN fiscal_month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}' AND
        '#{Date.yesterday.month}'  THEN harganetto1 END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}'  THEN sales_amount END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{2.month.ago.month}' THEN sales_amount END) val_2
      FROM sales_mart.RET1BRAND WHERE fiscal_month BETWEEN '#{Date.yesterday.last_month.beginning_of_year.to_date.month}'
      AND '#{Date.yesterday.last_month.month}' AND fiscal_year BETWEEN '#{Date.yesterday.last_month.beginning_of_year.to_date.year}'
      AND '#{Date.yesterday.last_month.year}' AND brand REGEXP '#{brand}' GROUP BY area_id
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(sales_amount) AS revenue, brand AS jenisbrgdisc FROM sales_mart.RET1BRAND WHERE
        fiscal_month = '#{Date.yesterday.last_month.last_year.month}' AND
        fiscal_year = '#{Date.yesterday.last_month.last_year.year}'
        AND brand REGEXP '#{brand}' GROUP BY brand
      ) AS ly ON lc.jenisbrgdisc = ly.jenisbrgdisc
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{Date.yesterday.last_month.month}' THEN amount END) month_target,
        SUM(CASE WHEN month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}' AND
        '#{Date.yesterday.last_month.end_of_year.month}' THEN amount END) year_target
        FROM dbmarketing.sales_target_values WHERE
        brand REGEXP '#{brand}' AND
        month BETWEEN '#{Date.yesterday.last_month.beginning_of_year.month}' AND
        '#{Date.yesterday.last_month.end_of_year.month}'
        AND year BETWEEN '#{Date.yesterday.last_month.beginning_of_year.year}' AND
        '#{Date.yesterday.last_month.end_of_year.year}' GROUP BY brand
      ) AS st ON lc.jenisbrgdisc = st.brand
    ")
  end

  def self.modern_nasional_this_month_total(date, brand)
    self.find_by_sql("SELECT lc.val_1, lc.val_2, ly.revenue, st.month_target, st.year_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val1_1 / st.month_target) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / st.year_target) * 100), 0) AS ty_percentage FROM
    (
      SELECT branch as area_id, brand as jenisbrgdisc,
      SUM(CASE WHEN
        fiscal_month IN ('#{date.last_month.month}','#{date.month}')
        AND fiscal_year BETWEEN '#{date.beginning_of_year.to_date.year}' AND '#{date.year}'
        THEN sales_amount END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) val_2
      FROM sales_mart.MM1BRAND WHERE fiscal_month IN ('#{date.last_month.month}','#{date.month}')
      AND fiscal_year BETWEEN '#{date.last_month.year}' AND '#{date.year}'
      AND brand REGEXP '#{brand}' GROUP BY brand
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(sales_amount) AS revenue, brand as jenisbrgdisc FROM sales_mart.MM1BRAND WHERE
        fiscal_month = '#{date.last_year.month}' AND fiscal_year = '#{date.last_year.year}' AND brand REGEXP '#{brand}' GROUP BY brand
      ) AS ly ON lc.jenisbrgdisc = ly.jenisbrgdisc
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{date.month}' THEN amount END) month_target,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' THEN amount END) year_target
        FROM sales_target_values WHERE
        brand REGEXP '#{brand}' AND
        month BETWEEN '#{Date.yesterday.beginning_of_year.month}' AND
        '#{Date.yesterday.end_of_year.month}'
        AND year BETWEEN '#{Date.yesterday.beginning_of_year.year}' AND
        '#{Date.yesterday.end_of_year.year}' GROUP BY brand
      ) AS st ON lc.jenisbrgdisc = st.brand
    ")
  end

  def self.direct_ecom_nasional_this_month_total(date, brand)
    self.find_by_sql("SELECT lc.val_1, lc.val_2, ly.revenue, st.month_target, st.year_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val1_1 / st.month_target) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / st.year_target) * 100), 0) AS ty_percentage FROM
    (
      SELECT branch as area_id, brand as jenisbrgdisc,
      SUM(CASE WHEN
        fiscal_month IN ('#{date.last_month.month}','#{date.month}')
        AND fiscal_year BETWEEN '#{date.beginning_of_year.to_date.year}' AND '#{date.year}'
        THEN sales_amount END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) val_2
      FROM sales_mart.EC1BRAND WHERE fiscal_month IN ('#{date.last_month.month}','#{date.month}')
      AND fiscal_year BETWEEN '#{date.last_month.year}' AND '#{date.year}'
      AND brand REGEXP '#{brand}' GROUP BY brand
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(sales_amount) AS revenue, brand as jenisbrgdisc FROM sales_mart.EC1BRAND WHERE
        fiscal_month = '#{date.last_year.month}' AND fiscal_year = '#{date.last_year.year}' AND brand REGEXP '#{brand}' GROUP BY brand
      ) AS ly ON lc.jenisbrgdisc = ly.jenisbrgdisc
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{date.month}' THEN amount END) month_target,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' THEN amount END) year_target
        FROM sales_target_values WHERE
        brand REGEXP '#{brand}' AND
        month BETWEEN '#{Date.yesterday.beginning_of_year.month}' AND
        '#{Date.yesterday.end_of_year.month}'
        AND year BETWEEN '#{Date.yesterday.beginning_of_year.year}' AND
        '#{Date.yesterday.end_of_year.year}' GROUP BY brand
      ) AS st ON lc.jenisbrgdisc = st.brand
    ")
  end

  def self.direct_nasional_this_month_total(date, brand)
    self.find_by_sql("SELECT lc.val_1, lc.val_2, ly.revenue, st.month_target, st.year_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val1_1 / st.month_target) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / st.year_target) * 100), 0) AS ty_percentage FROM
    (
      SELECT branch as area_id, brand as jenisbrgdisc,
      SUM(CASE WHEN
        fiscal_month IN ('#{date.last_month.month}','#{date.month}')
        AND fiscal_year BETWEEN '#{date.beginning_of_year.to_date.year}' AND '#{date.year}'
        THEN sales_amount END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) val_2
      FROM sales_mart.SH1BRAND WHERE fiscal_month IN ('#{date.last_month.month}','#{date.month}')
      AND fiscal_year BETWEEN '#{date.last_month.year}' AND '#{date.year}'
      AND brand REGEXP '#{brand}' GROUP BY brand
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(sales_amount) AS revenue, brand as jenisbrgdisc FROM sales_mart.SH1BRAND WHERE
        fiscal_month = '#{date.last_year.month}' AND fiscal_year = '#{date.last_year.year}' AND brand REGEXP '#{brand}' GROUP BY brand
      ) AS ly ON lc.jenisbrgdisc = ly.jenisbrgdisc
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{date.month}' THEN amount END) month_target,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' THEN amount END) year_target
        FROM sales_target_values WHERE
        brand REGEXP '#{brand}' AND
        month BETWEEN '#{Date.yesterday.beginning_of_year.month}' AND
        '#{Date.yesterday.end_of_year.month}'
        AND year BETWEEN '#{Date.yesterday.beginning_of_year.year}' AND
        '#{Date.yesterday.end_of_year.year}' GROUP BY brand
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
      SELECT area as area_id, brand as jenisbrgdisc,
      SUM(CASE WHEN
        fiscal_month IN ('#{date.last_month.month}','#{date.month}')
        AND fiscal_year BETWEEN '#{date.beginning_of_year.to_date.year}' AND '#{date.year}'
        THEN sales_amount END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) val_2
      FROM sales_mart.RET1BRAND WHERE fiscal_month IN ('#{date.last_month.month}','#{date.month}')
      AND fiscal_year BETWEEN '#{date.last_month.year}' AND '#{date.year}'
      AND brand REGEXP '#{brand}' GROUP BY brand
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(sales_amount) AS revenue, brand as jenisbrgdisc FROM sales_mart.RET1BRAND WHERE
        fiscal_month = '#{date.last_year.month}' AND fiscal_year = '#{date.last_year.year}' AND brand REGEXP '#{brand}' GROUP BY brand
      ) AS ly ON lc.jenisbrgdisc = ly.jenisbrgdisc
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{date.month}' THEN amount END) month_target,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' THEN amount END) year_target
        FROM sales_target_values WHERE
        brand REGEXP '#{brand}' AND
        month BETWEEN '#{Date.yesterday.beginning_of_year.month}' AND
        '#{Date.yesterday.end_of_year.month}'
        AND year BETWEEN '#{Date.yesterday.beginning_of_year.year}' AND
        '#{Date.yesterday.end_of_year.year}' GROUP BY brand
      ) AS st ON lc.jenisbrgdisc = st.brand
    ")
  end

  def self.modern_nasional_this_month_branches_store(date, brand)
    self.find_by_sql("SELECT st.area AS cabang, lc.customer, lc.customer_desc, lc.total FROM
    (
      SELECT branch as area_id, brand as jenisbrgdisc, SUM(sales_amount) as total, customer, customer_desc
      FROM sales_mart.MM2CUSBRAND WHERE fiscal_month = '#{date.month}'
      AND fiscal_year = '#{date.year}' AND brand REGEXP '#{brand}' GROUP BY branch, customer
    ) as lc
    LEFT JOIN direct_areas AS st
      ON lc.area_id = st.id
    ")
  end

  def self.direct_ecom_nasional_this_month_branches_store(date, brand)
    self.find_by_sql("SELECT st.area AS cabang, combine.customer, combine.customer_desc,
    IFNULL(order1.total_order, 0) AS total_order, IFNULL(sj.total_sj, 0) AS total_sj FROM
    (
      SELECT customer, branch, customer_desc FROM sales_mart.EC2CUSBRAND WHERE fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}'  GROUP BY customer
      UNION
      SELECT customer, branch, customer_desc FROM sales_mart.EC2CUSBRAND_ORDER WHERE fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' GROUP BY customer
    ) AS combine
    LEFT JOIN
    (
      SELECT customer, customer_desc, SUM(sales_amount) AS total_order FROM sales_mart.EC2CUSBRAND_ORDER
      WHERE fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND brand REGEXP '#{brand}' GROUP BY customer
    ) AS order1 ON combine.customer = order1.customer
    LEFT JOIN
    (
      SELECT customer, customer_desc, SUM(sales_amount) AS total_sj FROM sales_mart.EC2CUSBRAND
      WHERE fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND brand REGEXP '#{brand}'  GROUP BY customer
    ) AS sj ON combine.customer = sj.customer
    LEFT JOIN direct_areas AS st
      ON combine.branch = st.id
    ")
  end

  def self.direct_nasional_this_month_branches_store(date, brand)
    self.find_by_sql("SELECT st.area AS cabang, combine.customer, combine.customer_desc,
    IFNULL(order1.total_order, 0) AS total_order, IFNULL(sj.total_sj, 0) AS total_sj FROM
    (
      SELECT customer, branch, customer_desc FROM sales_mart.SH2CUSBRAND WHERE fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}'  GROUP BY customer
      UNION
      SELECT customer, branch, customer_desc FROM sales_mart.SH2CUSBRAND_ORDER WHERE fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' GROUP BY customer
    ) AS combine
    LEFT JOIN
    (
      SELECT customer, customer_desc, SUM(sales_amount) AS total_order FROM sales_mart.SH2CUSBRAND_ORDER
      WHERE fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND brand REGEXP '#{brand}' GROUP BY customer
    ) AS order1 ON combine.customer = order1.customer
    LEFT JOIN
    (
      SELECT customer, customer_desc, SUM(sales_amount) AS total_sj FROM sales_mart.SH2CUSBRAND
      WHERE fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND brand REGEXP '#{brand}'  GROUP BY customer
    ) AS sj ON combine.customer = sj.customer
    LEFT JOIN direct_areas AS st
      ON combine.branch = st.id
    ")
  end

  def self.modern_nasional_this_month_branches(date, brand)
    self.find_by_sql("SELECT st.area AS cabang, lc.val_1, lc.val_2, ly.revenue, st.month_target, st.year_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val1_1 / st.month_target) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / st.year_target) * 100), 0) AS ty_percentage FROM
    (
      SELECT branch as area_id, brand as jenisbrgdisc,
      SUM(CASE WHEN
        fiscal_month BETWEEN '#{date.beginning_of_year.to_date.month}' AND '#{date.month}'
        AND fiscal_year BETWEEN '#{date.beginning_of_year.to_date.year}' AND '#{date.year}'
        THEN sales_amount END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) val_2
      FROM sales_mart.MM1BRAND WHERE fiscal_month IN ('#{date.last_month.month}','#{date.month}')
      AND fiscal_year BETWEEN '#{date.last_month.year}' AND '#{date.year}'
      AND brand REGEXP '#{brand}' GROUP BY branch
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(sales_amount) AS revenue, branch as area_id FROM sales_mart.MM1BRAND WHERE
        fiscal_month = '#{date.last_year.month}' AND fiscal_year = '#{date.last_year.year}'
        AND brand REGEXP '#{brand}' GROUP BY branch
      ) AS ly ON lc.area_id = ly.area_id
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{date.month}' THEN amount END) month_target,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' THEN amount END) year_target
        FROM dbmarketing.sales_target_values WHERE
        brand REGEXP '#{brand}' AND
        month BETWEEN '#{date.beginning_of_year.month}' AND
        '#{date.end_of_year.month}'
        AND year BETWEEN '#{date.beginning_of_year.year}' AND
        '#{date.end_of_year.year}' GROUP BY branch
      ) AS st ON lc.area_id = st.branch
    LEFT JOIN direct_areas AS st
      ON lc.area_id = st.id
    ")
  end

  def self.direct_ecom_nasional_this_month_branches(date, brand)
    self.find_by_sql("SELECT st.area AS cabang, lc.val_1, lc.val_2, ly.revenue, st.month_target, st.year_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val1_1 / st.month_target) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / st.year_target) * 100), 0) AS ty_percentage FROM
    (
      SELECT branch as area_id, brand as jenisbrgdisc,
      SUM(CASE WHEN
        fiscal_month BETWEEN '#{date.beginning_of_year.to_date.month}' AND '#{date.month}'
        AND fiscal_year BETWEEN '#{date.beginning_of_year.to_date.year}' AND '#{date.year}'
        THEN sales_amount END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) val_2
      FROM sales_mart.EC1BRAND WHERE fiscal_month IN ('#{date.last_month.month}','#{date.month}')
      AND fiscal_year BETWEEN '#{date.last_month.year}' AND '#{date.year}'
      AND brand REGEXP '#{brand}' GROUP BY branch
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(sales_amount) AS revenue, branch as area_id FROM sales_mart.EC1BRAND WHERE
        fiscal_month = '#{date.last_year.month}' AND fiscal_year = '#{date.last_year.year}'
        AND brand REGEXP '#{brand}' GROUP BY branch
      ) AS ly ON lc.area_id = ly.area_id
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{date.month}' THEN amount END) month_target,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' THEN amount END) year_target
        FROM dbmarketing.sales_target_values WHERE
        brand REGEXP '#{brand}' AND
        month BETWEEN '#{date.beginning_of_year.month}' AND
        '#{date.end_of_year.month}'
        AND year BETWEEN '#{date.beginning_of_year.year}' AND
        '#{date.end_of_year.year}' GROUP BY branch
      ) AS st ON lc.area_id = st.branch
    LEFT JOIN direct_areas AS st
      ON lc.area_id = st.id
    ")
  end

  def self.direct_nasional_this_month_branches(date, brand)
    self.find_by_sql("SELECT st.area AS cabang, lc.val_1, lc.val_2, ly.revenue, st.month_target, st.year_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val1_1 / st.month_target) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / st.year_target) * 100), 0) AS ty_percentage FROM
    (
      SELECT branch as area_id, brand as jenisbrgdisc,
      SUM(CASE WHEN
        fiscal_month BETWEEN '#{date.beginning_of_year.to_date.month}' AND '#{date.month}'
        AND fiscal_year BETWEEN '#{date.beginning_of_year.to_date.year}' AND '#{date.year}'
        THEN sales_amount END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) val_2
      FROM sales_mart.SH1BRAND WHERE fiscal_month IN ('#{date.last_month.month}','#{date.month}')
      AND fiscal_year BETWEEN '#{date.last_month.year}' AND '#{date.year}'
      AND brand REGEXP '#{brand}' GROUP BY branch
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(sales_amount) AS revenue, branch as area_id FROM sales_mart.SH1BRAND WHERE
        fiscal_month = '#{date.last_year.month}' AND fiscal_year = '#{date.last_year.year}'
        AND brand REGEXP '#{brand}' GROUP BY branch
      ) AS ly ON lc.area_id = ly.area_id
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{date.month}' THEN amount END) month_target,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' THEN amount END) year_target
        FROM dbmarketing.sales_target_values WHERE
        brand REGEXP '#{brand}' AND
        month BETWEEN '#{date.beginning_of_year.month}' AND
        '#{date.end_of_year.month}'
        AND year BETWEEN '#{date.beginning_of_year.year}' AND
        '#{date.end_of_year.year}' GROUP BY branch
      ) AS st ON lc.area_id = st.branch
    LEFT JOIN direct_areas AS st
      ON lc.area_id = st.id
    ")
  end

  def self.retail_nasional_this_month_branches(date, brand)
    self.find_by_sql("SELECT st.area AS cabang, lc.val_1, lc.val_2, ly.revenue, st.month_target, st.year_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - ly.revenue) / ly.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val1_1 / st.month_target) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / st.year_target) * 100), 0) AS ty_percentage FROM
    (
      SELECT area as area_id, brand as jenisbrgdisc,
      SUM(CASE WHEN
        fiscal_month BETWEEN '#{date.beginning_of_year.to_date.month}' AND '#{date.month}'
        AND fiscal_year BETWEEN '#{date.beginning_of_year.to_date.year}' AND '#{date.year}'
        THEN sales_amount END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) val_2
      FROM sales_mart.RET1BRAND WHERE fiscal_month IN ('#{date.last_month.month}','#{date.month}')
      AND fiscal_year BETWEEN '#{date.last_month.year}' AND '#{date.year}'
      AND brand REGEXP '#{brand}' GROUP BY area
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(sales_amount) AS revenue, area as area_id FROM sales_mart.RET1BRAND WHERE
        fiscal_month = '#{date.last_year.month}' AND fiscal_year = '#{date.last_year.year}'
        AND brand REGEXP '#{brand}' GROUP BY area_id
      ) AS ly ON lc.area_id = ly.area_id
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{date.month}' THEN amount END) month_target,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' THEN amount END) year_target
        FROM dbmarketing.sales_target_values WHERE
        brand REGEXP '#{brand}' AND
        month BETWEEN '#{date.beginning_of_year.month}' AND
        '#{date.end_of_year.month}'
        AND year BETWEEN '#{date.beginning_of_year.year}' AND
        '#{date.end_of_year.year}' GROUP BY branch
      ) AS st ON lc.area_id = st.branch
    LEFT JOIN areas AS st
      ON lc.area_id = st.jde_id
    ")
  end

  def self.retail_nasional_year_branches(date, brand)
    self.find_by_sql("SELECT st.area AS cabang, lc.val_1, lc.val_2, lc.val_3, lc.val_4, lc.val_5,
    lc.val_6, lc.val_7, lc.val_8, lc.val_9, lc.val_10, lc.val_11, lc.val_12 FROM
    (
      SELECT branch as area_id, brand as jenisbrgdisc,
      SUM(CASE WHEN fiscal_month = '#{1.month.ago.month}' AND fiscal_year = '#{1.month.ago.year}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{2.month.ago.month}' AND fiscal_year = '#{2.month.ago.year}' THEN sales_amount END) val_2,
      SUM(CASE WHEN fiscal_month = '#{3.month.ago.month}' AND fiscal_year = '#{3.month.ago.year}' THEN sales_amount END) val_3,
      SUM(CASE WHEN fiscal_month = '#{4.month.ago.month}' AND fiscal_year = '#{4.month.ago.year}' THEN sales_amount END) val_4,
      SUM(CASE WHEN fiscal_month = '#{5.month.ago.month}' AND fiscal_year = '#{5.month.ago.year}' THEN sales_amount END) val_5,
      SUM(CASE WHEN fiscal_month = '#{6.month.ago.month}' AND fiscal_year = '#{6.month.ago.year}' THEN sales_amount END) val_6,
      SUM(CASE WHEN fiscal_month = '#{7.month.ago.month}' AND fiscal_year = '#{7.month.ago.year}' THEN sales_amount END) val_7,
      SUM(CASE WHEN fiscal_month = '#{8.month.ago.month}' AND fiscal_year = '#{8.month.ago.year}' THEN sales_amount END) val_8,
      SUM(CASE WHEN fiscal_month = '#{9.month.ago.month}' AND fiscal_year = '#{9.month.ago.year}' THEN sales_amount END) val_9,
      SUM(CASE WHEN fiscal_month = '#{10.month.ago.month}' AND fiscal_year = '#{10.month.ago.year}' THEN sales_amount END) val_10,
      SUM(CASE WHEN fiscal_month = '#{11.month.ago.month}' AND fiscal_year = '#{11.month.ago.year}' THEN sales_amount END) val_11,
      SUM(CASE WHEN fiscal_month = '#{12.month.ago.month}' AND fiscal_year = '#{12.month.ago.year}' THEN sales_amount END) val_12
      FROM sales_mart.RET1BRAND WHERE fiscal_month BETWEEN 1 AND 12
      AND fiscal_year BETWEEN '#{12.month.ago.year}' AND '#{date.year}'
      AND brand REGEXP '#{brand}' and branch != 23 GROUP BY area_id
    ) as lc
    LEFT JOIN areas AS st
      ON lc.area_id = st.id
    ")
  end

  def self.modern_nasional_this_month_branch(date, brand)
    self.find_by_sql("SELECT lc.harga, cb.area AS branch FROM (
    SELECT SUM(sales_amount) AS harga, branch FROM sales_mart.MM1BRAND
    WHERE fiscal_month = '#{date.month}'
    AND fiscal_year = '#{date.year}' AND branch NOT IN(1,5)
    AND brand REGEXP '#{brand}' GROUP BY branch) AS lc
    LEFT JOIN dbmarketing.direct_areas AS cb ON lc.branch = cb.id
    ORDER BY lc.harga DESC
    ")
  end

  def self.direct_ecom_nasional_this_month_branch(date, brand)
    self.find_by_sql("SELECT lc.harga, cb.area AS branch FROM (
    SELECT SUM(sales_amount) AS harga, branch FROM sales_mart.EC1BRAND
    WHERE fiscal_month = '#{date.month}'
    AND fiscal_year = '#{date.year}' AND branch NOT IN(1,5)
    AND brand REGEXP '#{brand}' GROUP BY branch) AS lc
    LEFT JOIN dbmarketing.direct_areas AS cb ON lc.branch = cb.id
    ORDER BY lc.harga DESC
    ")
  end

  def self.direct_nasional_this_month_branch(date, brand)
    self.find_by_sql("SELECT lc.harga, cb.area AS branch FROM (
    SELECT SUM(sales_amount) AS harga, branch FROM sales_mart.SH1BRAND
    WHERE fiscal_month = '#{date.month}'
    AND fiscal_year = '#{date.year}' AND branch NOT IN(1,5)
    AND brand REGEXP '#{brand}' GROUP BY branch) AS lc
    LEFT JOIN dbmarketing.direct_areas AS cb ON lc.branch = cb.id
    ORDER BY lc.harga DESC
    ")
  end

  def self.retail_nasional_this_month_branch(date, brand)
    self.find_by_sql("SELECT lc.harga, cb.area AS branch FROM (
    SELECT SUM(sales_amount) AS harga, branch FROM sales_mart.RET1BRAND
    WHERE fiscal_month = '#{date.month}'
    AND fiscal_year = '#{date.year}' AND branch NOT IN(1,5)
    AND brand REGEXP '#{brand}' GROUP BY branch) AS lc
    LEFT JOIN dbmarketing.areas AS cb ON lc.branch = cb.id
    ORDER BY lc.harga DESC
    ")
  end

  def self.target_retail_nasional_this_month(brand)
    self.find_by_sql("SELECT SUM(target) AS jumlah, month FROM sales_targets
    WHERE branch = '#{branch}' AND month BETWEEN '#{1.month.ago.beginning_of_year.month}'
    AND '#{Date.yesterday.month}' AND year = '#{1.month.ago.beginning_of_year.year}'
    AND brand REGEXP '#{brand}' AND area_id IS NOT NULL
    GROUP BY month, branch")
  end

  def self.modern_nasional_this_month(brand)
    self.find_by_sql("SELECT SUM(harganetto1) AS harga, fiscal_month FROM tblaporancabang
    WHERE fiscal_month BETWEEN '#{date.beginning_of_year.month}'
    AND '#{date.month}' AND fiscal_year = '#{date.beginning_of_year.year}'
    AND tipecust IN ('MODERN') AND jenisbrgdisc = '#{brand}' AND area_id IS NOT NULL

    GROUP BY fiscal_month")
  end

  def self.direct_ecom_nasional_this_month(brand)
    self.find_by_sql("SELECT SUM(harganetto1) AS harga, fiscal_month FROM tblaporancabang
    WHERE fiscal_month BETWEEN '#{date.beginning_of_year.month}'
    AND '#{date.month}' AND fiscal_year = '#{date.beginning_of_year.year}'
    AND tipecust IN ('DIRECT', 'SHOWROOM') AND jenisbrgdisc = '#{brand}' AND area_id IS NOT NULL

    GROUP BY fiscal_month")
  end

  def self.direct_nasional_this_month(brand)
    self.find_by_sql("SELECT SUM(harganetto1) AS harga, fiscal_month FROM tblaporancabang
    WHERE fiscal_month BETWEEN '#{date.beginning_of_year.month}'
    AND '#{date.month}' AND fiscal_year = '#{date.beginning_of_year.year}'
    AND tipecust IN ('DIRECT', 'SHOWROOM') AND jenisbrgdisc = '#{brand}' AND area_id IS NOT NULL

    GROUP BY fiscal_month")
  end

  def self.retail_nasional_this_month(brand)
    self.find_by_sql("SELECT SUM(harganetto1) AS harga, fiscal_month FROM tblaporancabang
    WHERE fiscal_month BETWEEN '#{date.beginning_of_year.month}'
    AND '#{date.month}' AND fiscal_year = '#{date.beginning_of_year.year}'
    AND tipecust = 'RETAIL' AND jenisbrgdisc = '#{brand}' AND area_id IS NOT NULL

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
        '#{Date.yesterday.last_month.month}'  THEN harganetto1 END) y_qty,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN jumlah END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}' THEN harganetto1 END) val_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.month}'  THEN harganetto1 END) val1_1,
      SUM(CASE WHEN fiscal_month = '#{Date.yesterday.last_month.last_month.month}' THEN harganetto1 END) val_2
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{date.last_month.beginning_of_month}'
      AND '#{date.to_date}' AND jenisbrgdisc = '#{brand}' AND area_id != 1 AND area_id != 50 AND
      tipecust = 'RETAIL'  AND area_id IS NOT NULL
      GROUP BY jenisbrgdisc, area_id
    ) as lc
    LEFT JOIN
      (
        SELECT SUM(harganetto1) AS revenue, area_id FROM tblaporancabang WHERE
        fiscal_month = '#{Date.yesterday.last_month.last_year.month}' AND fiscal_year = '#{Date.yesterday.last_month.last_year.year}'
        AND jenisbrgdisc = '#{brand}' AND area_id != 1 AND
        tipecust = 'RETAIL' AND area_id IS NOT NULL
        GROUP BY jenisbrgdisc, area_id
      ) AS ly ON lc.area_id = ly.area_id
    LEFT JOIN
      (
        SELECT branch, brand,
        SUM(CASE WHEN month = '#{Date.yesterday.last_month.month}' THEN amount END) month_target,
        SUM(CASE WHEN month BETWEEN '#{Date.yesterday.beginning_of_year.to_date.month}' AND
        '#{Date.yesterday.end_of_year.month}' THEN amount END) year_target
        FROM sales_target_values WHERE
        brand REGEXP '#{brand}' AND
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
    AND tipecust = 'RETAIL' AND jenisbrgdisc = '#{brand}'

    AND area_id NOT IN (1,50) AND area_id IS NOT NULL
    GROUP BY area_id) AS lc
    LEFT JOIN areas AS cb ON lc.area_id = cb.id
    ")
  end

  def self.target_retail_nasional_monthly(brand)
    self.find_by_sql("SELECT SUM(target) AS jumlah, month FROM sales_targets
    WHERE branch = '#{branch}' AND month BETWEEN '#{1.month.ago.beginning_of_year.month}'
    AND '#{Date.yesterday.last_month.month}' AND year = '#{1.month.ago.beginning_of_year.year}'
    AND brand REGEXP '#{brand}'
    GROUP BY month, branch")
  end

  def self.direct_nasional_monthly(brand)
    self.find_by_sql("SELECT SUM(harganetto1) AS harga, fiscal_month FROM tblaporancabang
    WHERE fiscal_month BETWEEN '#{1.month.ago.beginning_of_year.month}'
    AND '#{Date.yesterday.last_month.month}' AND fiscal_year = '#{1.month.ago.beginning_of_year.year}'
    AND tipecust IN ('DIRECT', 'SHOWROOM') AND jenisbrgdisc = '#{brand}'

    GROUP BY fiscal_month")
  end

  def self.retail_nasional_monthly(brand)
    self.find_by_sql("SELECT SUM(harganetto1) AS harga, fiscal_month FROM tblaporancabang
    WHERE fiscal_month BETWEEN '#{1.month.ago.beginning_of_year.month}'
    AND '#{Date.yesterday.last_month.month}' AND fiscal_year = '#{1.month.ago.beginning_of_year.year}'
    AND tipecust = 'RETAIL' AND jenisbrgdisc = '#{brand}'

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
      COUNT(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND diskon5 BETWEEN 4 AND 7 THEN diskon5 END) variance2,
      COUNT(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND diskon5 > 7 THEN diskon5 END) variance3,
      COUNT(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN diskon5 END) total_so
      FROM tblaporancabang WHERE fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}'
      AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL'
      ) as sub")
  end

  def self.monthly_article_summary(date, branch, brand)
    self.find_by_sql("SELECT article_desc, size, qty_1, qty_2, val_1, val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT article, article_desc, size,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month BETWEEN '#{date.last_month.month}' AND
        '#{date.month}' AND fiscal_year BETWEEN '#{date.last_month.year}' AND
        '#{date.year}' THEN sales_quantity END) qty_2,
      SUM(CASE WHEN fiscal_month BETWEEN '#{date.last_month.month}' AND
        '#{date.month}' AND fiscal_year BETWEEN '#{date.last_month.year}' AND
        '#{date.year}' THEN sales_amount END) val_2
      FROM sales_mart.RET1ARTICLE WHERE fiscal_month BETWEEN '#{date.last_month.month}' AND
        '#{date.month}' AND fiscal_year BETWEEN '#{date.last_month.year}' AND
        '#{date.year}' AND branch = '#{branch}' AND brand REGEXP '#{brand}'
      GROUP BY article, size
      ) as sub")
  end

  def self.monthly_salesman_summary(date, branch, brand)
    find_by_sql("SELECT lc.salesmen_desc, lc.qty_1, lc.qty_2, lc.val_1, lc.val_2,
    ROUND((((val_1 - val_2) / val_2) * 100), 0) AS percentage FROM
    (
      SELECT branch, salesmen_desc, salesmen,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_quantity END) qty_2,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) val_2
      FROM sales_mart.RET3SALBRAND WHERE fiscal_day <= '#{date.day}' AND
      fiscal_month IN ('#{date.last_month.month}','#{date.month}') AND fiscal_year BETWEEN '#{date.last_month.year}'
      AND '#{date.year}' AND area = '#{branch}' AND brand REGEXP '#{brand}'
      GROUP BY salesmen
    ) AS lc")
  end

  def self.monthly_city_summary(date, branch, brand)
    date = define_date(date)
    self.find_by_sql("SELECT city, product, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT city, product,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND product = 'KM' THEN sales_quantity END) km,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND product = 'HB' THEN sales_quantity END) hb,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND product = 'DV' THEN sales_quantity END) dv,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND product = 'SA' THEN sales_quantity END) sa,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND product = 'SB' THEN sales_quantity END) sb,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND product = 'KB' THEN sales_quantity END) kb,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) total_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) total_2
      FROM sales_mart.RET4CITYPRODUCT WHERE fiscal_day <= '#{date.day}' AND
      fiscal_month IN ('#{date.last_month.month}','#{date.month}') AND fiscal_year BETWEEN '#{date.last_month.year}'
      AND '#{date.year}' AND area = '#{branch}' AND brand REGEXP '#{brand}'
      GROUP BY city
      ) as sub")
  end

  def self.monthly_customer_summary(date, branch, brand)
    date = define_date(date)
    self.find_by_sql("SELECT customer_desc, product, km, dv, hb, sa, sb, kb, total_1, total_2,
    ROUND((((total_1 - total_2) / total_2) * 100), 0) AS percentage FROM
    (
      SELECT customer_desc, product,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND product = 'KM' THEN sales_quantity END) km,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND product = 'HB' THEN sales_quantity END) hb,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND product = 'DV' THEN sales_quantity END) dv,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND product = 'SA' THEN sales_quantity END) sa,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND product = 'SB' THEN sales_quantity END) sb,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' AND product = 'KB' THEN sales_quantity END) kb,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) total_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) total_2
      FROM sales_mart.RET2CUSPRODUCT WHERE fiscal_day <= '#{date.day}' AND
      fiscal_month IN ('#{date.last_month.month}','#{date.month}') AND fiscal_year BETWEEN '#{date.last_month.year}'
      AND '#{date.year}' AND area = '#{branch}' AND brand REGEXP '#{brand}'
      GROUP BY customer
      ) as sub")
  end

  def self.revenue_last_month(date, branch, brand)
    date = define_date(date)
    self.find_by_sql("SELECT lc.val_1, lc.val_2, lc.revenue, st.month_target,
    ROUND((((lc.val_1 - lc.val_2) / lc.val_2) * 100), 0) AS percentage,
    ROUND((((lc.val_1 - lc.revenue) / lc.revenue) * 100), 0) AS y_percentage,
    ROUND(((lc.val_1 / SUM(st.month_target)) * 100.0), 0) AS t_percentage,
    ROUND(((lc.y_qty / SUM(st.year_target)) * 100), 0) AS ty_percentage FROM
    (
      SELECT area,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) val_2,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.last_year.year}' THEN sales_amount END) revenue,
      SUM(CASE WHEN fiscal_month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.last_month.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) y_qty
      FROM sales_mart.RET1BRAND WHERE fiscal_day <= '#{date.day}' AND fiscal_month IN ('#{date.last_month.month}','#{date.month}')
      AND fiscal_year IN ('#{date.last_year.year}', '#{date.year}')
      AND area = '#{branch}' AND brand REGEXP '#{brand}'
    ) as lc
      LEFT JOIN
      (
        SELECT branch,
        SUM(CASE WHEN month = '#{date.month}' and year = '#{date.year}' THEN amount END) month_target,
        SUM(CASE WHEN month BETWEEN '#{date.beginning_of_year.to_date.month}' AND
        '#{date.end_of_year.month}' and year = '#{date.year}' THEN amount END) year_target
        FROM sales_target_values WHERE
        branch = '#{branch}' AND
        (brand REGEXP '#{brand}' OR brand IS NULL)
        AND month BETWEEN '#{date.beginning_of_year.month}' AND
        '#{date.end_of_year.month}'
        AND (year = '#{Date.yesterday.year}' OR year IS NULL)
      ) AS st ON lc.area = st.branch
    ")
  end

  def self.target_monthly_summaries(branch, brand)
    self.find_by_sql("SELECT SUM(target) AS jumlah, month FROM sales_targets
    WHERE branch = '#{branch}' AND month BETWEEN '#{1.month.ago.beginning_of_year.month}'
    AND '#{Date.yesterday.last_month.month}' AND year = '#{1.month.ago.beginning_of_year.year}'
    AND brand REGEXP '#{brand}'
    GROUP BY month, branch")
  end

  def self.monthly_summaries(branch, brand)
    self.find_by_sql("SELECT SUM(sales_quantity) AS jumlah, fiscal_month FROM sales_mart.RET1BRAND
    WHERE branch = '#{branch}' AND fiscal_month BETWEEN '#{ 1.month.ago.beginning_of_year.month}'
    AND '#{Date.yesterday.last_month.month}' AND fiscal_year = '#{1.month.ago.beginning_of_year.year}'
    AND brand REGEXP '#{brand}' GROUP BY branch, fiscal_month")
  end

  def self.monthly_product_summary(date, branch, brand)
    date = define_date(date)
    # self.find_by_sql("SELECT lc.product, lc.qty_1, lc.qty_2, lc.val_1, lc.val_2,
    # ROUND((((lc.val_1 - lc.val_2) /lc. val_2) * 100), 0) AS percentage,
    # ROUND(((lc.qty_1/SUM(st.target)) * 100.0), 0) AS target FROM
    # (
    # SELECT product,
    # SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_quantity END) qty_1,
    # SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val_1,
    # SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_quantity END) qty_2,
    # SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) val_2
    # FROM sales_mart.RET1PRODUCT WHERE fiscal_month BETWEEN '#{date.last_month.month}'
    # AND '#{date.month}' AND branch = '#{branch}' AND brand REGEXP '#{brand}'
    # GROUP BY product
    # ) as lc
    # RIGHT JOIN sales_targets AS st
    # ON lc.product = st.product AND (st.brand REGEXP '#{brand}' OR st.brand IS NULL) AND
    # (st.branch = '#{branch}' OR st.branch IS NULL)
    # AND (st.month = '#{date.month}' OR st.month IS NULL)
    # AND (st.year = '#{date.year}' OR st.year IS NULL) GROUP BY st.product
    # ")

    self.find_by_sql("SELECT lc.product, lc.qty_1, lc.qty_2, lc.val_1, lc.val_2,
    ROUND((((lc.val_1 - lc.val_2) /lc. val_2) * 100), 0) AS percentage FROM
    (
      SELECT product,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN fiscal_month = '#{date.month}' AND fiscal_year = '#{date.year}' THEN sales_amount END) val_1,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_quantity END) qty_2,
      SUM(CASE WHEN fiscal_month = '#{date.last_month.month}' AND fiscal_year = '#{date.last_month.year}' THEN sales_amount END) val_2
      FROM sales_mart.RET1PRODUCT WHERE fiscal_day <= '#{date.day}' AND
      fiscal_month IN ('#{date.last_month.month}','#{date.month}')
      AND '#{date.month}' AND area = '#{branch}' AND brand REGEXP '#{brand}'
      GROUP BY product
      ) as lc
      ")
  end

  def self.monthly_summary(branch, brand)
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND
    MONTH(tanggalsj) = '#{Date.today.month}' AND YEAR(tanggalsj) = '#{Date.today.year}' AND jenisbrgdisc = '#{brand}' AND
    tipecust = 'RETAIL' GROUP BY jenisbrgdisc")
  end
  ########## END MONTHLY

  ########## MOST ITEMS
  def self.most_items_ordered_weekly(branch, brand)
    self.find_by_sql("SELECT lc.namaartikel AS article, lc.kodejenis as jenis, lc.qty_4, lc.val_4, lc.qty_3, lc.val_3,
    lc.qty_2, lc.val_2, lc.qty_1, lc.val_1 FROM
    (
      SELECT namaartikel, kodejenis,
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
      '#{1.week.ago.end_of_week.to_date}' AND jenisbrgdisc REGEXP '#{brand}' AND area_id = '#{branch}' AND
      tipecust = 'RETAIL' and kodejenis IN ('KM', 'HB', 'DV', 'SA', 'SB', 'ST', 'KB')
      GROUP BY namaartikel ORDER BY most DESC
      ) as lc")
  end

  def self.most_items_ordered_monthly(branch, brand)
    self.find_by_sql("SELECT namaartikel, ordered, lebar, value FROM (
    SELECT kodejenis, namaartikel, lebar, SUM(jumlah) AS ordered, SUM(harganetto1) AS value FROM tblaporancabang
    WHERE area_id = '#{branch}' AND MONTH(tanggalsj) = '#{1.month.ago.to_date.month}' AND
    YEAR(tanggalsj) = '#{1.month.ago.to_date.year}' AND tipecust = 'RETAIL' AND AND jenisbrgdisc regexp '#{brand}'
    and kodejenis IN ('KM', 'HB', 'DV', 'SA', 'SB', 'ST', 'KB') GROUP BY namaartikel, lebar) totals ORDER BY ordered DESC LIMIT 10")
  end
  ########## END MOST ITEMS

  ########## CUSTOMER
  def self.customer_summary_monthly(branch, brand)
    self.find_by_sql("SELECT customer, salesman, SUM(jumlah) AS ordered, SUM(harganetto1) AS price,
    jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND MONTH(tanggalsj) = '#{1.month.ago.to_date.month}' AND
    YEAR(tanggalsj) = '#{1.month.ago.to_date.year}' AND tipecust = 'RETAIL' AND jenisbrgdisc regexp '#{brand}' GROUP BY customer")
  end

  def self.customer_summary(branch, brand)
    beginning_of_week = 1.week.ago.to_date.beginning_of_week.to_date
    end_of_week = 1.week.ago.to_date.end_of_week.to_date
    self.find_by_sql("SELECT customer, salesman, SUM(jumlah) AS ordered, SUM(harganetto1) AS price,
    jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND tanggalsj BETWEEN '#{beginning_of_week}'
    AND '#{end_of_week}' AND tipecust = 'RETAIL' AND jenisbrgdisc regexp '#{brand}'
    and kodejenis IN ('KM', 'HB', 'DV', 'SA', 'SB', 'ST', 'KB') GROUP BY customer")
  end
  ########## END CUSTOMER

  ########## CHANNEL
  def self.monthly_channel(branch, brand)
    self.find_by_sql("SELECT SUM(jumlah) AS jumlah, tipecust FROM tblaporancabang WHERE area_id = '#{branch}' AND
    MONTH(tanggalsj) = '#{1.month.ago.month}' AND YEAR(tanggalsj) = '#{1.month.ago.year}' AND jenisbrgdisc regexp '#{brand}' AND
    tipecust = 'RETAIL' GROUP BY tipecust")
  end

  def self.weekly_channel(branch, brand)
    beginning_of_week = 1.week.ago.to_date.beginning_of_week.to_date
    end_of_week = 1.week.ago.to_date.end_of_week.to_date
    self.find_by_sql("SELECT SUM(jumlah) AS jumlah, tipecust FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc regexp '#{brand}' AND
    tipecust = 'RETAIL' and kodejenis IN ('KM', 'HB', 'DV', 'SA', 'SB', 'ST', 'KB') GROUP BY tipecust")
  end
  ########## END CHANNEL

  ########## START WEEKLY

  def self.retail_nasional_weekly(brand)
    self.find_by_sql("SELECT SUM(harganetto1) AS val, CONCAT('WEEK ', week) AS weekly_name FROM tblaporancabang
    WHERE week BETWEEN '#{5.weeks.ago.to_date.cweek}'
    AND '#{1.weeks.ago.to_date.cweek}' AND fiscal_year BETWEEN '#{5.weeks.ago.to_date.year}' AND '#{1.weeks.ago.to_date.year}'
    AND tipecust = 'RETAIL' AND jenisbrgdisc REGEXP '#{brand}' and kodejenis IN ('KM', 'HB', 'DV', 'SA', 'SB', 'ST', 'KB')
    GROUP BY week")
  end

  def self.modern_nasional_weekly(brand)
    self.find_by_sql("SELECT SUM(sales_amount) AS val, CONCAT('WEEK ', week) AS weekly_name FROM sales_mart.MM1BRAND
    WHERE week BETWEEN '#{5.weeks.ago.to_date.cweek}'
    AND '#{1.weeks.ago.to_date.cweek}' AND fiscal_year BETWEEN '#{5.weeks.ago.to_date.year}' AND '#{1.weeks.ago.to_date.year}'
    AND brand REGEXP '#{brand}'
    GROUP BY week")
  end

  def self.direct_nasional_weekly(brand)
    self.find_by_sql("SELECT SUM(sales_amount) AS val, CONCAT('WEEK ', week) AS weekly_name FROM sales_mart.SH1BRAND
    WHERE week BETWEEN '#{5.weeks.ago.to_date.cweek}'
    AND '#{1.weeks.ago.to_date.cweek}' AND fiscal_year BETWEEN '#{5.weeks.ago.to_date.year}' AND '#{1.weeks.ago.to_date.year}'
    AND brand REGEXP '#{brand}'
    GROUP BY week")
  end

  def self.modern_nasional_weekly_branch(brand)
    self.find_by_sql("SELECT st.area AS cabang, lc.qty_4, lc.val_4, lc.qty_3, lc.val_3,
    lc.qty_2, lc.val_2, lc.qty_1, lc.val_1, ROUND((((val_3 - val_4)/val_4) * 100)) AS chg_3,
    ROUND((((val_2 - val_3)/val_3) * 100)) AS chg_2, ROUND((((val_1 - val_2)/val_2) * 100)) AS chg_1 FROM
    (
      SELECT branch,
      SUM(CASE WHEN week = '#{4.weeks.ago.to_date.cweek}' AND fiscal_year = '#{4.weeks.ago.year}' THEN sales_quantity END) qty_4,
      SUM(CASE WHEN week = '#{4.weeks.ago.to_date.cweek}' AND fiscal_year = '#{4.weeks.ago.year}' THEN sales_amount END) val_4,
      SUM(CASE WHEN week = '#{3.weeks.ago.to_date.cweek}' AND fiscal_year = '#{3.weeks.ago.year}' THEN sales_quantity END) qty_3,
      SUM(CASE WHEN week = '#{3.weeks.ago.to_date.cweek}' AND fiscal_year = '#{3.weeks.ago.year}' THEN sales_amount END) val_3,
      SUM(CASE WHEN week = '#{2.weeks.ago.to_date.cweek}' AND fiscal_year = '#{2.weeks.ago.year}' THEN sales_quantity END) qty_2,
      SUM(CASE WHEN week = '#{2.weeks.ago.to_date.cweek}' AND fiscal_year = '#{2.weeks.ago.year}' THEN sales_amount END) val_2,
      SUM(CASE WHEN week = '#{1.week.ago.to_date.cweek}' AND fiscal_year = '#{1.weeks.ago.year}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN week = '#{1.week.ago.to_date.cweek}' AND fiscal_year = '#{1.weeks.ago.year}' THEN sales_amount END) val_1
      FROM sales_mart.MM1BRAND WHERE week BETWEEN '#{4.week.ago.to_date.cweek}'
      AND '#{1.week.ago.to_date.cweek}' AND fiscal_year BETWEEN '#{4.week.ago.year}'
      AND '#{1.week.ago.year}' AND brand REGEXP '#{brand}' AND branch != 1
      GROUP BY branch
      ) as lc
      LEFT JOIN direct_areas AS st
      ON lc.branch = st.id")
  end

  def self.direct_nasional_weekly_branch(brand)
    self.find_by_sql("SELECT st.area AS cabang, lc.qty_4, lc.val_4, lc.qty_3, lc.val_3,
    lc.qty_2, lc.val_2, lc.qty_1, lc.val_1, ROUND((((val_3 - val_4)/val_4) * 100)) AS chg_3,
    ROUND((((val_2 - val_3)/val_3) * 100)) AS chg_2, ROUND((((val_1 - val_2)/val_2) * 100)) AS chg_1 FROM
    (
      SELECT branch,
      SUM(CASE WHEN week = '#{4.weeks.ago.to_date.cweek}' AND fiscal_year = '#{4.weeks.ago.year}' THEN sales_quantity END) qty_4,
      SUM(CASE WHEN week = '#{4.weeks.ago.to_date.cweek}' AND fiscal_year = '#{4.weeks.ago.year}' THEN sales_amount END) val_4,
      SUM(CASE WHEN week = '#{3.weeks.ago.to_date.cweek}' AND fiscal_year = '#{3.weeks.ago.year}' THEN sales_quantity END) qty_3,
      SUM(CASE WHEN week = '#{3.weeks.ago.to_date.cweek}' AND fiscal_year = '#{3.weeks.ago.year}' THEN sales_amount END) val_3,
      SUM(CASE WHEN week = '#{2.weeks.ago.to_date.cweek}' AND fiscal_year = '#{2.weeks.ago.year}' THEN sales_quantity END) qty_2,
      SUM(CASE WHEN week = '#{2.weeks.ago.to_date.cweek}' AND fiscal_year = '#{2.weeks.ago.year}' THEN sales_amount END) val_2,
      SUM(CASE WHEN week = '#{1.week.ago.to_date.cweek}' AND fiscal_year = '#{1.weeks.ago.year}' THEN sales_quantity END) qty_1,
      SUM(CASE WHEN week = '#{1.week.ago.to_date.cweek}' AND fiscal_year = '#{1.weeks.ago.year}' THEN sales_amount END) val_1
      FROM sales_mart.SH1BRAND WHERE week BETWEEN '#{4.week.ago.to_date.cweek}'
      AND '#{1.week.ago.to_date.cweek}' AND fiscal_year BETWEEN '#{4.week.ago.year}'
      AND '#{1.week.ago.year}' AND brand REGEXP '#{brand}' AND branch != 1
      GROUP BY branch
      ) as lc
      LEFT JOIN direct_areas AS st
      ON lc.branch = st.id")
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
      AND '#{1.week.ago.year}' AND jenisbrgdisc REGEXP '#{brand}' AND area_id != 1 AND
      tipecust = 'RETAIL' and kodejenis IN ('KM', 'HB', 'DV', 'SA', 'SB', 'ST', 'KB')
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
      AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL' and kodejenis IN ('KM', 'HB', 'DV', 'SA', 'SB', 'ST', 'KB') GROUP BY kota")
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
      AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL' and kodejenis IN ('KM', 'HB', 'DV', 'SA', 'SB', 'ST', 'KB') GROUP BY kodejenis")
  end

  def self.weekly_summary(branch, brand)
    beginning_of_week = Date.today.beginning_of_week
    end_of_week = Date.today.end_of_week
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc REGEXP '#{brand}' AND
    tipecust = 'RETAIL' and kodejenis IN ('KM', 'HB', 'DV', 'SA', 'SB', 'ST', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.a_week_ago(branch, brand)
    beginning_of_week = 1.week.ago.beginning_of_week.to_date
    end_of_week = 1.week.ago.end_of_week.to_date
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc REGEXP '#{brand}' AND
    tipecust = 'RETAIL' and kodejenis IN ('KM', 'HB', 'DV', 'SA', 'SB', 'ST', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.two_weeks_ago(branch, brand)
    beginning_of_week = 2.week.ago.beginning_of_week.to_date
    end_of_week = 2.week.ago.end_of_week.to_date
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc REGEXP '#{brand}' AND
    tipecust = 'RETAIL' and kodejenis IN ('KM', 'HB', 'DV', 'SA', 'SB', 'ST', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.three_weeks_ago(branch, brand)
    beginning_of_week = 3.week.ago.beginning_of_week.to_date
    end_of_week = 3.week.ago.end_of_week.to_date
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc REGEXP '#{brand}' AND
    tipecust = 'RETAIL' and kodejenis IN ('KM', 'HB', 'DV', 'SA', 'SB', 'ST', 'KB') GROUP BY jenisbrgdisc")
  end

  def self.four_weeks_ago(branch, brand)
    beginning_of_week = 4.week.ago.beginning_of_week.to_date
    end_of_week = 4.week.ago.end_of_week.to_date
    self.find_by_sql("SELECT tanggalsj, SUM(jumlah) AS jumlah, SUM(harganetto1) AS price, jenisbrgdisc FROM tblaporancabang WHERE area_id = '#{branch}' AND
    tanggalsj BETWEEN '#{beginning_of_week}' AND '#{end_of_week}' AND jenisbrgdisc REGEXP '#{brand}' AND
    tipecust = 'RETAIL' and kodejenis IN ('KM', 'HB', 'DV', 'SA', 'SB', 'ST', 'KB') GROUP BY jenisbrgdisc")
  end
  ########## END WEEKLY

  def self.define_date(date)
    (date.month == Date.today.month) ? Date.today : date.end_of_month
  end
end
