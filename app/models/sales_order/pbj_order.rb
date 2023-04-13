class SalesOrder::PbjOrder < ActiveRecord::Base
  self.table_name = "sales_mart.ORDER_MANAGEMENTS"

  def self.pbj_report(start_date, end_date, brand)
    find_by_sql("
        SELECT om.date, om.branch_plan, om.branch, om.brand, SUM(om.qty_pbjm) AS qty_pbjm, SUM(qty_pbjo) AS qty_pbjo, SUM(amount_pbjm) AS amount_pbjm,
            SUM(amount_pbjo) AS amount_pbjo,  stv.target FROM sales_mart.ORDER_MANAGEMENTS om 
            LEFT JOIN 
            (
              SELECT SUM(amount) AS target, branch, MONTH, YEAR, brand FROM dbmarketing.sales_target_values stv 
              GROUP BY MONTH, YEAR, branch, brand
            ) stv ON om.branch_id = stv.branch 
            AND (MONTH(om.date) = stv.month  AND YEAR(om.date) = stv.year AND om.brand = stv.brand)
            WHERE om.date BETWEEN '#{start_date}' AND '#{end_date}' AND om.brand = '#{brand}'
            GROUP BY MONTH(om.date), YEAR(om.date), om.branch_id, om.brand, stv.branch;
        ")
  end
end