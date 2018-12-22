class Penjualan::Customer < Penjualan::Sale
  def self.list_customers(branch, state, brand)
    CustomerBrand.find_by_sql("
      SELECT customer, MAX(tanggalsj) AS tanggalsj,
      SUM(CASE WHEN fiscal_month = '#{3.months.ago.month}' AND fiscal_year = '#{2.months.ago.year}' THEN total END) three_month,
      SUM(CASE WHEN fiscal_month = '#{2.months.ago.month}' AND fiscal_year = '#{2.months.ago.year}' THEN total END) two_month,
      SUM(CASE WHEN fiscal_month = '#{1.months.ago.month}' AND fiscal_year = '#{1.months.ago.year}' THEN total END) last_month,
      SUM(CASE WHEN fiscal_month = '#{Date.today.month}' AND fiscal_year = '#{Date.today.year}' THEN total END) this_month
      FROM customer_active WHERE
      branch = '#{branch}' AND tanggalsj >= '#{3.months.ago.to_date}' AND brand = '#{brand}' AND
      tipecust = 'RETAIL' GROUP BY kode_customer")
  end

  def self.list_customers_inactive(branch, state, brand)
    CustomerBrand.find_by_sql("
      SELECT cus.* FROM customer_active cus WHERE cus.id = (
        SELECT cus2.id FROM customer_active cus2 WHERE cus2.branch = '#{branch}' AND
        cus2.kode_customer = cus.kode_customer AND cus2.brand = '#{brand}' AND
        cus2.tipecust = 'RETAIL' ORDER BY cus2.tanggalsj DESC LIMIT 1
      ) AND cus.tanggalsj  < '#{3.months.ago.to_date}';
    ")
  end

  def self.active_customers(branch)
    date = 1.month.ago.to_date
    find_by_sql("
      SELECT brand, area_id, total, new_customer, active_customer, inactive_customer
      FROM sales_mart.CUSTOMER_GROWTHS WHERE area_id = '#{branch}' AND
      fmonth = '#{date.month}' AND fyear = '#{date.year}'
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
        tipecust = 'RETAIL' AND bonus = '-'
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
        tipecust = 'RETAIL' AND bonus = '-'
        GROUP BY kode_customer, fiscal_month, fiscal_year
      ) lc ON new_cus.address_number = lc.kode_customer AND lc.fiscal_month = MONTH(new_cus.opened_date)
        AND lc.fiscal_year = YEAR(new_cus.opened_date)
      LEFT JOIN
      (
        SELECT kode_customer, area_id, SUM(harganetto1) AS second_month, fiscal_month, fiscal_year
        FROM tblaporancabang WHERE area_id != 1 AND area_id != 50 AND
        tipecust = 'RETAIL' AND bonus = '-'
        GROUP BY kode_customer, fiscal_month, fiscal_year
      ) lc1 ON new_cus.address_number = lc1.kode_customer AND lc1.fiscal_month = MONTH(new_cus.opened_date + INTERVAL 1 MONTH)
        AND lc1.fiscal_year = YEAR(new_cus.opened_date)
      LEFT JOIN
      (
        SELECT kode_customer, area_id, SUM(harganetto1) AS third_month, fiscal_month, fiscal_year
        FROM tblaporancabang WHERE area_id != 1 AND area_id != 50 AND
        tipecust = 'RETAIL' AND bonus = '-'
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

  def self.reporting_customer_monthly(branch, brand)
    find_by_sql("SELECT customer, kode_customer, kota, salesman,
      SUM(CASE WHEN fiscal_month = '#{3.months.ago.month}' AND fiscal_year = '#{3.months.ago.year}' THEN harganetto1 END) month3,
      SUM(CASE WHEN fiscal_month = '#{2.months.ago.month}' AND fiscal_year = '#{2.months.ago.year}' THEN harganetto1 END) month2,
      SUM(CASE WHEN fiscal_month = '#{1.months.ago.month}' AND fiscal_year = '#{1.months.ago.year}' THEN harganetto1 END) month1,
      SUM(CASE WHEN fiscal_month = '#{Date.today.month}' AND fiscal_year = '#{Date.today.year}' THEN harganetto1 END) monthnow
      FROM tblaporancabang WHERE tanggalsj BETWEEN '#{3.months.ago.beginning_of_month.to_date}' AND '#{Date.today}'
      AND area_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND
      tipecust = 'RETAIL' AND bonus = '-'
      GROUP BY kode_customer
    ")
  end

  def self.reporting_customers(month, year, branch)
    find_by_sql("SELECT customer_desc as customer, customer as kode_customer,
      SUM(CASE WHEN brand = 'ELITE' THEN sales_amount END) elite,
      SUM(CASE WHEN brand = 'SERENITY' THEN sales_amount END) serenity,
      SUM(CASE WHEN brand = 'LADY' THEN sales_amount END) lady,
      SUM(CASE WHEN brand = 'ROYAL' THEN sales_amount END) royal
      FROM sales_mart.RET2CUSBRAND WHERE fiscal_month = '#{month}'
      AND fiscal_year = '#{year}'
      AND branch = '#{branch}'
      GROUP BY customer
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