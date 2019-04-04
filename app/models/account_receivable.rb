class AccountReceivable < ActiveRecord::Base

  def self.customer_collectable(date, brand, branch)
    find_by_sql("SELECT ar.customer, ar.salesman, ar.open_amount, bd.bad_debt FROM
      (
        SELECT
        SUM(CASE WHEN fiscal_month = '#{1.month.ago.month}' AND fiscal_year = '#{1.month.ago.year}' THEN open_amount END) open_amount,
        customer, salesman, due_date, brand, branch FROM
        account_receivables WHERE branch = '#{branch}' AND brand = '#{brand}'
        GROUP BY customer, brand
      ) AS ar
      LEFT JOIN
      (
        SELECT
        SUM(CASE WHEN fiscal_month < '#{1.month.ago.month}' AND fiscal_year = '#{2.month.ago.year}' THEN open_amount END) bad_debt,
        customer, salesman, due_date, brand, branch FROM
        account_receivables GROUP BY customer
      ) AS bd ON bd.customer = ar.customer AND bd.brand = ar.brand AND bd.branch = ar.branch
    ")
  end

  def self.find_collectable_percentage(brand, branch)
    find_by_sql("
      SELECT ROUND(((ib.invoiced/st.sales_total)*100.0),2) AS percent, 'C New Monthly Collectable' AS description
        FROM
        (
          SELECT (SUM(gross_amount)-SUM(open_amount)) AS invoiced,
          branch FROM account_receivables WHERE branch = '#{branch}' AND
          brand = '#{brand}' AND fiscal_month = '#{5.days.ago.month}' AND
          fiscal_year = '#{5.days.ago.year}'
        ) ib
        LEFT JOIN
        (
          SELECT SUM(gross_amount) AS sales_total,
          branch FROM account_receivables WHERE branch = '#{branch}'AND
          brand = '#{brand}' AND fiscal_month = '#{5.days.ago.month}' AND
          fiscal_year = '#{5.days.ago.year}'
        ) st ON ib.branch = st.branch
      UNION
        SELECT ROUND(((ib.invoiced/(st.st + st.bd))*100),2) AS percent, 'C Collectable This Month' AS description
        FROM
        (
          SELECT (SUM(gross_amount)-SUM(open_amount)) AS invoiced,
          branch FROM account_receivables WHERE branch = '#{branch}' AND
          brand = '#{brand}' AND fiscal_month = '#{5.days.ago.month}' AND
          fiscal_year = '#{5.days.ago.year}'
        ) ib
        LEFT JOIN
        (
          SELECT branch,
          SUM(CASE WHEN fiscal_month = '#{5.days.ago.month}' AND fiscal_year = '#{5.days.ago.year}' THEN gross_amount END) st,
          SUM(CASE WHEN due_date < '#{5.days.ago.beginning_of_month.to_date}' THEN open_amount END) bd FROM
          account_receivables WHERE branch = '#{branch}' AND
          brand = '#{brand}' AND due_date < '#{5.days.ago.end_of_month.to_date}'
        ) st ON ib.branch = st.branch
      UNION
        SELECT ROUND(((bd.gross_amount/(st.st + st.bd))*100),2) AS percent, 'C Bad Debt' AS description
        FROM
        (
          SELECT branch, SUM(open_amount) AS gross_amount
          FROM account_receivables WHERE branch = '#{branch}' AND
          brand = '#{brand}' AND due_date < '#{5.days.ago.beginning_of_month.to_date}'
        ) bd
        LEFT JOIN
        (
          SELECT branch,
          SUM(CASE WHEN fiscal_month = '#{5.days.ago.month}' AND fiscal_year = '#{5.days.ago.year}' THEN gross_amount END) st,
          SUM(CASE WHEN due_date < '#{5.days.ago.beginning_of_month.to_date}' THEN open_amount END) bd FROM
          account_receivables WHERE branch = '#{branch}' AND
          brand = '#{brand}' AND due_date < '#{5.days.ago.end_of_month.to_date}'
        ) st ON bd.branch = st.branch
      UNION
        SELECT ROUND(((bd.gross_amount/(st.st + st.bd))*100),2) AS percent, 'C Overdue Pass' AS description
        FROM
        (
          SELECT branch, SUM(open_amount) AS gross_amount
          FROM account_receivables WHERE branch = '#{branch}' AND
          brand = '#{brand}' AND fiscal_month = '#{5.days.ago.month}' AND
          fiscal_year = '#{5.days.ago.year}'
        ) bd
        LEFT JOIN
        (
          SELECT branch,
          SUM(CASE WHEN fiscal_month = '#{5.days.ago.month}' AND fiscal_year = '#{5.days.ago.year}' THEN gross_amount END) st,
          SUM(CASE WHEN due_date < '#{5.days.ago.beginning_of_month.to_date}' THEN open_amount END) bd FROM
          account_receivables WHERE branch = '#{branch}' AND
          brand = '#{brand}' AND due_date < '#{5.days.ago.end_of_month.to_date}'
        ) st ON bd.branch = st.branch

    ")
  end

  def self.find_collectable(brand, branch)
    find_by_sql("
      SELECT SUM(gross_amount) AS gross_amount, 'A TOP Sales Total' AS description
      FROM account_receivables WHERE branch = '#{branch}' AND
      brand = '#{brand}' AND fiscal_month = '#{5.days.ago.month}' AND
      fiscal_year = '#{5.days.ago.year}'
    UNION
      SELECT SUM(open_amount) AS gross_amount, 'A Bad Debt' AS description
      FROM account_receivables WHERE branch = '#{branch}' AND
      brand = '#{brand}' AND due_date < '#{5.days.ago.beginning_of_month.to_date}'
    UNION
      SELECT (SUM(gross_amount)-SUM(open_amount)) AS gross_amount, 'B TOP Invoiced Bill' AS description
      FROM account_receivables WHERE branch = '#{branch}' AND
      brand = '#{brand}' AND fiscal_month = '#{5.days.ago.month}' AND
      fiscal_year = '#{5.days.ago.year}'
    UNION
      SELECT SUM(open_amount) AS gross_amount, 'B TOP Invoices' AS description
      FROM account_receivables WHERE branch = '#{branch}' AND
      brand = '#{brand}' AND fiscal_month = '#{5.days.ago.month}' AND
      fiscal_year = '#{5.days.ago.year}'
    UNION
      SELECT (ar.st + ar.bd) AS gross_amount, 'A Total' AS description FROM
      (
        SELECT SUM(CASE WHEN fiscal_month = '#{5.days.ago.month}' AND fiscal_year = '#{5.days.ago.year}' THEN gross_amount END) st,
        SUM(CASE WHEN due_date < '#{5.days.ago.beginning_of_month.to_date}' THEN open_amount END) bd FROM
        account_receivables WHERE branch = '#{branch}' AND
        brand = '#{brand}' AND due_date < '#{5.days.ago.end_of_month.to_date}'
      ) ar
      ")
  end

  def self.find_uncollectable10(brand, branch)
    find_by_sql("SELECT customer, SUM(open_amount) AS open_amount, salesman, due_date FROM account_receivables WHERE
    branch = '#{branch}' AND brand = '#{brand}' AND fiscal_month <= '#{1.month.ago.month}' AND
    fiscal_year <= '#{1.month.ago.year}' AND open_amount != 0 GROUP BY customer_number, brand, fiscal_month, fiscal_year")
  end

  def self.find_uncollectable20(brand, branch)
    find_by_sql("SELECT customer, SUM(open_amount) AS open_amount, salesman, due_date FROM account_receivables WHERE
    branch = '#{branch}' AND brand = '#{brand}' AND fiscal_month > '#{1.month.ago.month}' AND
    fiscal_year >= '#{1.month.ago.year}' AND open_amount != 0 GROUP BY customer_number, brand, fiscal_month, fiscal_year")
  end
end