class SalesProductivity < ActiveRecord::Base
  
  def self.retail_productivity(branch, brand)
    self.find_by_sql("SELECT lc.jumlah, lc.salesman, lc.tanggalsj, sp.entry, (lc.jumlah/(sp.entry*8)) AS prod FROM
    (
     SELECT SUM(jumlah) AS jumlah, salesman, tanggalsj FROM tblaporancabang WHERE 
     tanggalsj BETWEEN '#{Date.yesterday.last_month.beginning_of_month.to_date}' AND
     '#{Date.yesterday.last_month.end_of_month.to_date}' AND kodejenis IN ('KM', 'KB') AND
     bonus = '-' AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}' AND tipecust = 'RETAIL' 
     GROUP BY tanggalsj
    ) AS lc
    LEFT JOIN
    (
      SELECT COUNT(*) AS entry, branch_id, date FROM sales_productivities WHERE branch_id = '#{branch}' AND
      brand = '#{brand}' AND branch_id = '#{branch}' GROUP BY date
    ) AS sp ON sp.date = lc.tanggalsj
    
    ")
  end
  
  def self.retail_success_rate(branch, brand)
    self.find_by_sql("SELECT sp.salesmen_id, sp.npvnc, sp.nvc, sp.ncdv, sp.ncc, sp.ncdc,
    usr.nama, lc.jumlah FROM
    (
      SELECT salesmen_id, SUM(npvnc) AS npvnc, SUM(nvc) AS nvc, SUM(ncdv) AS ncdv, SUM(ncc) AS ncc, SUM(ncdc) AS ncdc 
      FROM sales_productivities WHERE branch_id = '#{branch}' AND brand = '#{brand}' AND 
      month = '#{Date.yesterday.last_month.month}' AND year = '#{Date.yesterday.last_month.year}' 
      GROUP BY salesmen_id
    ) AS sp
    LEFT JOIN
    (
     SELECT nama, id, address_number FROM users
    ) AS usr ON sp.salesmen_id = usr.id
    LEFT JOIN
    (
     SELECT SUM(jumlah) AS jumlah, cabang_id, nopo FROM tblaporancabang WHERE fiscal_month = '#{Date.yesterday.last_month.month}' 
     AND fiscal_year = '#{Date.yesterday.last_month.year}' AND jenisbrgdisc = '#{brand}' AND 
     tipecust = 'RETAIL' AND bonus = '-' AND 
     kodejenis IN ('KM', 'KB') AND orty = 'SO'
    ) AS lc ON lc.nopo = sp.salesmen_id")
  end
end