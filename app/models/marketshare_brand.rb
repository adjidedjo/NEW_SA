class MarketshareBrand < ActiveRecord::Base
  belongs_to :marketshare,  inverse_of: :marketshares
  def self.customers(area, brand, user)
    find_by_sql("
      SELECT * FROM marketshare_brands ms WHERE
      ms.created_at >= '#{1.months.ago.to_date}' AND ms.area_id = '#{area}'
      and
      IF('#{user}' = 'admin', ms.internal_brand = 0, ms.internal_brand = '#{brand}')
      GROUP BY ms.name, ms.customer_name;
    ")
  end
end