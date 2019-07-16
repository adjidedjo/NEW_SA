class MarketshareBrand < ActiveRecord::Base
  belongs_to :marketshare,  inverse_of: :marketshares
  def self.customers(area, brand, user)
    find_by_sql("
      SELECT ms.customer_name, ms.city, ms.start_date, ms.end_date, ms.internal_brand, ms.name, SUM(ms.amount) AS amount FROM marketshare_brands ms WHERE ms.created_at >= '#{1.months.ago.beginning_of_month.to_date}'
      AND ms.area_id = '#{area}' AND IF('#{user}' = 'admin', ms.internal_brand = 0, ms.internal_brand = '#{brand}')
      GROUP BY ms.name, ms.customer_name, ms.internal_brand
      UNION
      SELECT r.customer_desc, r.city, CONCAT('0',fiscal_month,'/',fiscal_year) ,
      CONCAT('0', fiscal_month,'/',fiscal_year), brand, brand, SUM(r.sales_amount)
      FROM sales_mart.RET2CUSBRAND r WHERE branch = '#{area}' AND IF('admin' = 'admin', brand = 0, brand = '#{brand}')
      AND fiscal_month = '#{1.month.ago.month}' AND fiscal_year = 2019 GROUP BY branch, customer, brand;
    ")
  end
end