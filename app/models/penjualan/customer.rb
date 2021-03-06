class Penjualan::Customer < Penjualan::Sale
  def self.list_customers(branch, state, brand)
    if state == '0'
      CustomerBrand.find_by_sql("
        SELECT cb.customer, cb.last_order, lc.last_month, lc.two_month, lc.three_month  FROM
        (
          SELECT * FROM customer_brands WHERE
          branch = '#{branch}' AND last_order < '#{3.months.ago.to_date}' AND brand = '#{brand}' AND
          channel_group = 'RETAIL'
        ) as cb
        LEFT JOIN
          (
            SELECT kode_customer,
            SUM(CASE WHEN fiscal_month = '#{6.months.ago.to_date.month}' THEN harganetto1 END) three_month,
            SUM(CASE WHEN fiscal_month = '#{5.months.ago.to_date.month}' THEN harganetto1 END) two_month,
            SUM(CASE WHEN fiscal_month = '#{4.months.ago.to_date.month}' THEN harganetto1 END) last_month
            FROM tblaporancabang WHERE fiscal_month BETWEEN '#{6.months.ago.to_date.month}'
            AND '#{4.months.ago.to_date.month}' AND fiscal_year BETWEEN '#{6.months.ago.to_date.year}'
            AND '#{4.months.ago.to_date.year}' AND jenisbrgdisc = '#{brand}' AND area_id != 1 AND area_id != 50 AND
            tipecust = 'RETAIL' AND bonus = '-' AND area_id IS NOT NULL
            GROUP BY kode_customer
          ) AS lc ON lc.kode_customer = cb.address_number
      ")
    else
      CustomerBrand.find_by_sql("
        SELECT cb.customer, cb.last_order, lc.last_month, lc.two_month, lc.three_month  FROM
        (
          SELECT * FROM customer_brands WHERE
          branch = '#{branch}' AND last_order BETWEEN '#{3.months.ago.to_date}' AND '#{1.month.ago.to_date}' AND brand = '#{brand}' AND
          channel_group = 'RETAIL'
        ) as cb
        LEFT JOIN
          (
            SELECT kode_customer,
            SUM(CASE WHEN fiscal_month = '#{3.months.ago.to_date.month}' THEN harganetto1 END) three_month,
            SUM(CASE WHEN fiscal_month = '#{2.months.ago.to_date.month}' THEN harganetto1 END) two_month,
            SUM(CASE WHEN fiscal_month = '#{1.months.ago.to_date.month}' THEN harganetto1 END) last_month
            FROM tblaporancabang WHERE fiscal_month BETWEEN '#{3.months.ago.to_date.month}'
            AND '#{1.months.ago.to_date.month}' AND fiscal_year BETWEEN '#{3.months.ago.to_date.year}'
            AND '#{1.months.ago.to_date.year}' AND jenisbrgdisc = '#{brand}' AND area_id != 1 AND area_id != 50 AND
            tipecust = 'RETAIL' AND bonus = '-' AND area_id IS NOT NULL
            GROUP BY kode_customer
          ) AS lc ON lc.kode_customer = cb.address_number
      ")
    end
  end

  def self.active_customers(branch)
    CustomerBrand.find_by_sql("
      SELECT brand,
        COUNT(CASE WHEN last_order > '#{3.months.ago.to_date}' THEN id END) active,
        COUNT(CASE WHEN last_order <= '#{3.months.ago.to_date}' THEN id END) inactive,
        branch
        FROM customer_brands WHERE branch = '#{branch}' AND
        channel_group = 'RETAIL' AND brand != '' GROUP BY brand
    ")
  end

  def self.nasional_customers_last_order
    find_by_sql("
      SELECT new_cus.address_number, new_cus.name, new_cus.city, new_cus.opened_date, new_cus.last_order_date,
      st.Cabang AS cabang, lc.first_month FROM
      (
        SELECT address_number, name, city, opened_date, last_order_date
          FROM jde_customers WHERE last_order_date < '#{3.months.ago.beginning_of_month.to_date}'
          AND i_class = 'RET'
      ) new_cus
      LEFT JOIN
      (
        SELECT kode_customer, area_id, SUM(harganetto1) AS first_month, fiscal_month, fiscal_year
        FROM tblaporancabang WHERE area_id != 1 AND area_id != 50 AND
        tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
        GROUP BY kode_customer, fiscal_month, fiscal_year
      ) lc ON new_cus.address_number = lc.kode_customer AND lc.fiscal_month = MONTH(new_cus.last_order_date)
        AND lc.fiscal_year = YEAR(new_cus.last_order_date)
      LEFT JOIN tbidcabang AS st
        ON lc.area_id = st.id
    ")
  end

  def self.nasional_new_growth
    find_by_sql("
      SELECT new_cus.address_number, new_cus.name, new_cus.city, new_cus.opened_date,
      st.Cabang AS cabang, lc.first_month, lc1.second_month, lc2.third_month,
      ROUND((((lc1.second_month - lc.first_month) / lc.first_month) * 100), 0) change1,
      ROUND((((lc2.third_month - lc1.second_month) / lc1.second_month) * 100), 0) change2 FROM
      (
        SELECT address_number, name, city, opened_date
          FROM jde_customers WHERE opened_date BETWEEN '#{3.month.ago.beginning_of_month.to_date}'
          AND '#{Date.yesterday.to_date}' AND i_class = 'RET'
      ) new_cus
      LEFT JOIN
      (
        SELECT kode_customer, area_id, SUM(harganetto1) AS first_month, fiscal_month, fiscal_year
        FROM tblaporancabang WHERE area_id != 1 AND area_id != 50 AND
        tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
        GROUP BY kode_customer, fiscal_month, fiscal_year
      ) lc ON new_cus.address_number = lc.kode_customer AND lc.fiscal_month = MONTH(new_cus.opened_date)
        AND lc.fiscal_year = YEAR(new_cus.opened_date)
      LEFT JOIN
      (
        SELECT kode_customer, area_id, SUM(harganetto1) AS second_month, fiscal_month, fiscal_year
        FROM tblaporancabang WHERE area_id != 1 AND area_id != 50 AND
        tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
        GROUP BY kode_customer, fiscal_month, fiscal_year
      ) lc1 ON new_cus.address_number = lc1.kode_customer AND lc1.fiscal_month = MONTH(new_cus.opened_date + INTERVAL 1 MONTH)
        AND lc1.fiscal_year = YEAR(new_cus.opened_date)
      LEFT JOIN
      (
        SELECT kode_customer, area_id, SUM(harganetto1) AS third_month, fiscal_month, fiscal_year
        FROM tblaporancabang WHERE area_id != 1 AND area_id != 50 AND
        tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
        GROUP BY kode_customer, fiscal_month, fiscal_year
      ) lc2 ON new_cus.address_number = lc2.kode_customer AND lc2.fiscal_month = MONTH(new_cus.opened_date + INTERVAL 2 MONTH)
        AND lc2.fiscal_year = YEAR(new_cus.opened_date)
      LEFT JOIN tbidcabang AS st
      ON lc.area_id = st.id OR lc1.area_id = st.id OR lc2.area_id = st.id
    ")
  end

  def self.nasional_customers_stat
    find_by_sql("
      SELECT third, second, first, this_month FROM
      (
        SELECT COUNT(DISTINCT(CASE WHEN tanggalsj BETWEEN '#{3.month.ago.beginning_of_month.to_date}'
          AND '#{3.month.ago.end_of_month.to_date}' THEN kode_customer END)) third,
          COUNT(DISTINCT(CASE WHEN tanggalsj BETWEEN '#{2.month.ago.beginning_of_month.to_date}'
          AND '#{2.month.ago.end_of_month.to_date}' THEN kode_customer END)) second,
          COUNT(DISTINCT(CASE WHEN tanggalsj BETWEEN '#{1.month.ago.beginning_of_month.to_date}'
          AND '#{1.month.ago.end_of_month.to_date}' THEN kode_customer END)) first,
          COUNT(DISTINCT(CASE WHEN tanggalsj BETWEEN '#{Date.yesterday.beginning_of_month.to_date}'
          AND '#{Date.yesterday}' THEN kode_customer END)) this_month
          FROM tblaporancabang WHERE tanggalsj BETWEEN '#{3.month.ago.beginning_of_month.to_date}'
          AND '#{Date.yesterday}' AND tipecust = 'RETAIL'
      ) AS cs
    ")
  end

  def self.total_customers
    find_by_sql("
      SELECT COUNT(id) AS total FROM jde_customers WHERE i_class = 'RET'
    ")
  end

  def self.total_new_customers
    find_by_sql("
      SELECT COUNT(id) AS total FROM jde_customers WHERE YEAR(opened_date) =
      '#{Date.yesterday.year}' AND i_class = 'RET'
    ")
  end

  def self.reporting_customers(month, year, branch)
    find_by_sql("SELECT customer, kode_customer,
      SUM(CASE WHEN jenisbrgdisc = 'ELITE' THEN harganetto1 END) elite,
      SUM(CASE WHEN jenisbrgdisc = 'SERENITY' THEN harganetto1 END) serenity,
      SUM(CASE WHEN jenisbrgdisc = 'LADY' THEN harganetto1 END) lady,
      SUM(CASE WHEN jenisbrgdisc = 'ROYAL' THEN harganetto1 END) royal
      FROM tblaporancabang WHERE fiscal_month = '#{month}'
      AND fiscal_year = '#{year}'
      AND area_id != 1 AND area_id != 50
      AND area_id = '#{branch}'AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'SA', 'SB', 'ST', 'KB')
      GROUP BY kode_customer
    ")
  end

  def self.nasional_new_customers_stat
    find_by_sql("
      SELECT third, second, first, this_month, ROUND(((second - third)/third * 100), 5) AS change3,
      ROUND(((first - second)/second * 100), 5) AS change2,
      ROUND(((this_month - first)/first * 100), 5) AS change1 FROM
      (
        SELECT COUNT(CASE WHEN opened_date BETWEEN '#{3.month.ago.beginning_of_month.to_date}'
          AND '#{3.month.ago.end_of_month.to_date}' THEN id END) third,
          COUNT(CASE WHEN opened_date BETWEEN '#{2.month.ago.beginning_of_month.to_date}'
          AND '#{2.month.ago.end_of_month.to_date}' THEN id END) second,
          COUNT(CASE WHEN opened_date BETWEEN '#{1.month.ago.beginning_of_month.to_date}'
          AND '#{1.month.ago.end_of_month.to_date}' THEN id END) first,
          COUNT(CASE WHEN opened_date BETWEEN '#{Date.yesterday.beginning_of_month.to_date}'
          AND '#{Date.yesterday}' THEN id END) this_month
          FROM jde_customers WHERE opened_date BETWEEN '#{3.month.ago.beginning_of_month.to_date}'
          AND '#{Date.yesterday}' AND i_class = 'RET'
      ) AS cs
    ")
  end
end