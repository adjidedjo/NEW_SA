class AsongOrder < ActiveRecord::Base
  
  def self.calculation_asong_by_branch(start_date, end_date, area)
    find_by_sql("
      SELECT ao.brand, SUM(ap.point) AS point, SUM(ao.quantity) AS qty FROM asong_orders ao
      INNER JOIN asong_points ap ON ao.id = ap.asong_order_id
      WHERE ao.order_date BETWEEN '#{start_date.to_date}' AND '#{end_date.to_date}'
      AND ao.branch = '#{area}' GROUP BY ao.brand;
    ")
  end
end