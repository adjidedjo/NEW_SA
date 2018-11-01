class MarketshareBrand < ActiveRecord::Base
  belongs_to :marketshare,  inverse_of: :marketshares
  
  def self.customers(user, area, brand)
    find_by_sql("
      SELECT mb.customer_name, mb.city, mb.amount, ms.start_date, ms.end_date, ms.brand, mb.name
      FROM marketshares ms INNER JOIN marketshare_brands mb ON mb.marketshare_id = ms.id
      WHERE ms.created_at >= '2018-01-01' AND ms.area_id = '#{area}' and ms.brand = '#{brand}';
    ")
  end
end