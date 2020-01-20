class Penjualan::Customer < Penjualan::Sale
  def self.customer_decrease(brand)
    date = Date.today
    find_by_sql("

      SELECT cb.Cabang AS cabang, b.* FROM (
        SELECT a.area_id, a.customer, a.kode_customer, a.jenisbrgdisc, a.kota,
          IFNULL(SUM(CASE WHEN a.week = '#{4.weeks.ago.to_date.cweek}' THEN a.harganetto2 END), 0) AS w4,
          IFNULL(SUM(CASE WHEN a.week = '#{3.weeks.ago.to_date.cweek}' THEN a.harganetto2 END), 0) AS w3,
          IFNULL(SUM(CASE WHEN a.week = '#{2.weeks.ago.to_date.cweek}' THEN a.harganetto2 END), 0) AS w2,
          IFNULL(SUM(CASE WHEN a.week = '#{1.weeks.ago.to_date.cweek}' THEN a.harganetto2 END), 0) AS w1
          FROM (
            SELECT jenisbrgdisc, area_id, customer, kode_customer, kota, harganetto2, WEEK, fiscal_year
            FROM dbmarketing.tblaporancabang
            WHERE tanggalsj BETWEEN '#{5.weeks.ago.to_date}' AND '#{1.weeks.ago.to_date}' AND jenisbrgdisc REGEXP '#{brand}' AND tipecust = 'RETAIL'
            AND area_id IS NOT NULL
          ) a GROUP BY a.customer, a.jenisbrgdisc
      ) b
      LEFT JOIN
      (
        SELECT * FROM dbmarketing.tbidcabang
      ) cb ON cb.id = b.area_id
      WHERE b.w4 > b.w3 AND b.w4 > b.w2 AND b.w4 > b.w1 ORDER BY b.customer
    ")
  end

  def self.list_customers(branch, brand)
    find_by_sql("
      SELECT cd.customer, cd.city, cd.cust_status, cd.salesman, cd.brand,
        IFNULL(lkh.customer, 'NOT VISITED') AS customer_visit,
        lkh.brand AS customer_brand_visit, SUM(IF(lkh.cv IS NULL, 0, 1)) AS 'is_visit?',
        lkh.date_visit AS 'tanggal visit', MAX(cd.last_invoice) AS last_invoice FROM
        (
          SELECT * FROM sales_mart.CUSTOMER_DETGROWTHS
          WHERE branch = '#{branch}' AND brand REGEXP '#{brand}' and fmonth = '#{3.days.ago.month - 1}'
          and fyear = '#{3.days.ago.year}' GROUP BY customer, brand
        ) AS cd
        LEFT JOIN
        (
          SELECT spc.*, sales.nama, spc.call_visit AS cv, sp.date AS date_visit, sp.brand FROM
          (
            SELECT * FROM sales_productivities WHERE MONTH = '#{3.days.ago.month - 1}' AND YEAR = '#{3.days.ago.year}'
            AND branch_id = '#{branch}' AND brand REGEXP '#{brand}'
          ) AS sp
          LEFT JOIN
          (
            SELECT * FROM sales_productivity_customers
          ) AS spc ON spc.sales_productivity_id = sp.id
          LEFT JOIN
          (
            SELECT * FROM salesmen
          ) AS sales ON sales.id = sp.salesmen_id
        ) AS lkh ON lkh.customer = cd.customer
      GROUP BY customer")
  end

  def self.list_customers_inactive(branch, state, brand)
    CustomerBrand.find_by_sql("
      SELECT cus.* FROM customer_active cus WHERE cus.id = (
        SELECT cus2.id FROM customer_active cus2 WHERE cus2.branch = '#{branch}' AND
        cus2.kode_customer = cus.kode_customer AND cus2.brand REGEXP '#{brand}' AND
        cus2.tipecust = 'RETAIL' ORDER BY cus2.tanggalsj DESC LIMIT 1
      ) AND cus.tanggalsj  < '#{3.months.ago.to_date}';
    ")
  end

  def self.active_customers(branch)
    date = 1.month.ago.to_date
    date2 = date - 1.month
    find_by_sql("
      SELECT a.*, b.active_customer AS active_1month, b.inactive_customer AS inactive_1month,
       (a.new_customer/a.total)*100 AS growth_customer,
       ((a.active_customer - b.active_customer)/a.total)*100 AS growth_active,
       ((a.inactive_customer - b.inactive_customer)/a.total)*100 AS growth_inactive FROM (
        SELECT brand, area_id, total, new_customer, active_customer, inactive_customer
            FROM sales_mart.CUSTOMER_GROWTHS WHERE area_id = '#{branch}' AND
            fmonth = '#{date.month}' AND fyear = '#{date.year}'
        ) AS a
        LEFT JOIN
        (
        SELECT brand, area_id, total, new_customer, active_customer, inactive_customer
              FROM sales_mart.CUSTOMER_GROWTHS WHERE fmonth = '#{date2.month}' AND fyear = '#{date2.year}'
        ) AS b ON a.area_id = b.area_id AND a.brand REGEXP b.brand
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
        tipecust = 'RETAIL'
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
        tipecust = 'RETAIL'
        GROUP BY kode_customer, fiscal_month, fiscal_year
      ) lc ON new_cus.address_number = lc.kode_customer AND lc.fiscal_month = MONTH(new_cus.opened_date)
        AND lc.fiscal_year = YEAR(new_cus.opened_date)
      LEFT JOIN
      (
        SELECT kode_customer, area_id, SUM(harganetto1) AS second_month, fiscal_month, fiscal_year
        FROM tblaporancabang WHERE area_id != 1 AND area_id != 50 AND
        tipecust = 'RETAIL'
        GROUP BY kode_customer, fiscal_month, fiscal_year
      ) lc1 ON new_cus.address_number = lc1.kode_customer AND lc1.fiscal_month = MONTH(new_cus.opened_date + INTERVAL 1 MONTH)
        AND lc1.fiscal_year = YEAR(new_cus.opened_date)
      LEFT JOIN
      (
        SELECT kode_customer, area_id, SUM(harganetto1) AS third_month, fiscal_month, fiscal_year
        FROM tblaporancabang WHERE area_id != 1 AND area_id != 50 AND
        tipecust = 'RETAIL'
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
      AND area_id = '#{branch}' AND jenisbrgdisc REGEXP '#{brand}' AND
      tipecust = 'RETAIL'
      GROUP BY kode_customer
    ")
  end

  def self.reporting_customers(month, year, branch)
    find_by_sql("SELECT customer_desc as customer, customer as kode_customer,
      SUM(CASE WHEN brand REGEXP 'ELITE' THEN sales_amount END) elite,
      SUM(CASE WHEN brand IN ('SERENITY', 'CLASSIC') THEN sales_amount END) serenity,
      SUM(CASE WHEN brand REGEXP 'LADY' THEN sales_amount END) lady,
      SUM(CASE WHEN brand REGEXP 'ROYAL' THEN sales_amount END) royal
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
