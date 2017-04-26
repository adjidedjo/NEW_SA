class AccountReceivable < ActiveRecord::Base
  
  def self.find_collectable(brand, branch)
    find_by_sql("
      SELECT SUM(gross_amount) AS gross_amount, 'A Sales Total' AS description 
      FROM account_receivables WHERE branch = '#{branch}' AND 
      brand = '#{brand}' AND fiscal_month = '#{Date.today.month}' AND 
      fiscal_year = '#{Date.today.year}'
    UNION
      SELECT SUM(open_amount) AS gross_amount, 'A Bad Debt' AS description
      FROM account_receivables WHERE branch = '#{branch}' AND
      brand = '#{brand}' AND due_date < '#{Date.today.beginning_of_month.to_date}'
    UNION
      SELECT (SUM(gross_amount)-SUM(open_amount)) AS gross_amount, 'B Invoiced Bill' AS description
      FROM account_receivables WHERE branch = '#{branch}' AND 
      brand = '#{brand}' AND fiscal_month = '#{Date.today.month}' AND 
      fiscal_year = '#{Date.today.year}'
    UNION
      SELECT SUM(open_amount) AS gross_amount, 'B Invoices' AS description
      FROM account_receivables WHERE branch = '#{branch}' AND
      brand = '#{brand}' AND fiscal_month = '#{Date.today.month}' AND 
      fiscal_year = '#{Date.today.year}'
    UNION
      SELECT (ar.st + ar.bd) AS gross_amount, 'A Total' AS description FROM
      (
        SELECT SUM(CASE WHEN fiscal_month = '#{Date.today.month}' AND fiscal_year = '#{Date.today.year}' THEN gross_amount END) st,
        SUM(CASE WHEN due_date < '#{Date.today.beginning_of_month.to_date}' THEN open_amount END) bd FROM
        account_receivables WHERE branch = '#{branch}' AND
        brand = '#{brand}' AND due_date < '#{Date.today.end_of_month.to_date}'
      ) ar
      ")
  end
  
  def self.find_uncollectable10(brand, branch)
    find_by_sql("SELECT customer, SUM(open_amount) AS open_amount, salesman FROM account_receivables WHERE branch = '#{branch}' AND brand = '#{brand}' AND
    due_date BETWEEN '#{10.days.ago.to_date}' AND '#{1.days.ago.to_date}' AND pay_status != 'P' GROUP BY customer_number")
  end
  
  def self.find_uncollectable20(brand, branch)
    find_by_sql("SELECT customer, SUM(open_amount) AS open_amount, salesman FROM account_receivables WHERE branch = '#{branch}' AND brand = '#{brand}' AND
    due_date BETWEEN '#{20.days.ago.to_date}' AND '#{11.days.ago.to_date}' AND pay_status != 'P' GROUP BY customer_number")
  end
  
  def self.find_uncollectable31(brand, branch)
    find_by_sql("SELECT customer, SUM(open_amount) AS open_amount, salesman FROM account_receivables WHERE branch = '#{branch}' AND brand = '#{brand}' AND
    due_date BETWEEN '#{31.days.ago.to_date}' AND '#{21.days.ago.to_date}' AND pay_status != 'P' GROUP BY customer_number")
  end
  
  def self.find_uncollectable100(brand, branch)
    find_by_sql("SELECT customer, SUM(open_amount) AS open_amount, salesman FROM account_receivables WHERE branch = '#{branch}' AND brand = '#{brand}' AND
    due_date < '#{31.days.ago.to_date}' AND pay_status != 'P' GROUP BY customer_number")
  end
end