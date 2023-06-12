class SalesOrder::PbjOrder < ActiveRecord::Base
  self.table_name = "sales_mart.ORDER_MANAGEMENTS"

  def self.pbj_report(start_date, end_date, brand)
    find_by_sql("
        SELECT om.date, om.branch_plan, om.branch, om.brand, SUM(om.qty_pbjm) AS qty_pbjm, SUM(qty_pbjo) AS qty_pbjo, SUM(amount_pbjm) AS amount_pbjm,
            SUM(amount_pbjo) AS amount_pbjo,  stv.target FROM sales_mart.ORDER_MANAGEMENTS om 
            LEFT JOIN 
            (
              SELECT SUM(amount) AS target, branch, MONTH, YEAR, brand FROM dbmarketing.sales_target_values stv 
              WHERE MONTH BETWEEN MONTH('#{start_date.to_date}') AND MONTH('#{end_date.to_date}') AND 
              YEAR BETWEEN YEAR('#{start_date.to_date}') AND YEAR('#{end_date.to_date}')
              GROUP BY branch, brand
            ) stv ON om.branch_id = stv.branch 
            AND (om.brand LIKE CONCAT(stv.brand, '%'))
            WHERE om.date BETWEEN '#{start_date}' AND '#{end_date}' AND om.brand like '#{brand}%'
            GROUP BY om.branch_id, om.brand, stv.branch;
        ")
  end
end
