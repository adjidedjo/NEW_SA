class SalesProductivity < ActiveRecord::Base
  def self.retail_productivity(branch, brand)
    self.find_by_sql("SELECT cb.nama, lc.cabang_id, lc.jenisbrgdisc, lc.jumlah, lc.salesman,
    lc.tanggalsj, sp.salesmen, (lc.jumlah/(sp.salesmen*8)) AS prod FROM
    (
     SELECT cabang_id, jenisbrgdisc, SUM(jumlah) AS jumlah, salesman, tanggalsj FROM tblaporancabang WHERE
     tanggalsj BETWEEN '#{1.week.ago.to_date}' AND
     '#{Date.yesterday.to_date}' AND kodejenis IN ('KM','DV','HB','KB') AND
     bonus = '-' AND tipecust = 'RETAIL' AND cabang_id = '#{branch}' AND jenisbrgdisc = '#{brand}'
     GROUP BY tanggalsj
    ) AS lc
    LEFT JOIN
    (
      SELECT COUNT(salesmen_id) AS salesmen, branch_id, brand,
      date FROM sales_productivities GROUP BY brand, branch_id, date
    ) AS sp ON sp.date = lc.tanggalsj AND sp.branch_id = lc.cabang_id AND sp.brand = lc.jenisbrgdisc
    LEFT JOIN
    (
      SELECT id, nama FROM salesmen
    ) AS cb ON cb.id = sp.salesmen

    ")
  end

  def self.retail_success_rate(branch, brand)
    self.find_by_sql("SELECT sp.count_sales, sp.salesmen_id, sp.npvnc, sp.nvc, sp.ncdv, sp.ncc, sp.ncdc,
      us.nama, lc.jumlah FROM
      (
        SELECT COUNT(salesmen_id) AS count_sales, salesmen_id, SUM(npvnc) AS npvnc, SUM(nvc) AS nvc, SUM(ncdv) AS ncdv, SUM(ncc) AS ncc, SUM(ncdc) AS ncdc
        FROM sales_productivities WHERE branch_id = '#{branch}' AND brand = '#{brand}' AND
        month = '#{Date.yesterday.month}' AND year = '#{Date.yesterday.year}'
        GROUP BY salesmen_id
      ) AS sp
      LEFT JOIN
      (
       SELECT id, nama, nik FROM salesmen
      ) AS us ON sp.salesmen_id = us.id
      LEFT JOIN
      (
       SELECT SUM(jumlah) AS jumlah, cabang_id, nopo FROM tblaporancabang WHERE fiscal_month = '#{Date.yesterday.month}'
       AND fiscal_year = '#{Date.yesterday.year}' AND jenisbrgdisc = '#{brand}' AND
       tipecust = 'RETAIL' AND bonus = '-' AND
       kodejenis IN ('KM','DV','HB','KB') AND orty = 'SO'
      ) AS lc ON lc.nopo = us.nik
    ")
  end

  def self.retail_success_rate_all_branch
    self.find_by_sql("SELECT sp.count_sales, sp.salesmen_id, sp.npvnc, sp.nvc, sp.ncdv, sp.ncc, sp.ncdc,
      us.nama, lc.jumlah, cb.Cabang, sp.brand FROM
      (
        SELECT COUNT(salesmen_id) AS count_sales, salesmen_id, SUM(npvnc) AS npvnc, SUM(nvc) AS nvc,
        SUM(ncdv) AS ncdv, SUM(ncc) AS ncc, SUM(ncdc) AS ncdc, brand, branch_id
        FROM sales_productivities WHERE month = '#{Date.yesterday.month}' AND year = '#{Date.yesterday.year}'
        GROUP BY salesmen_id, branch_id, brand
      ) AS sp
      LEFT JOIN
      (
       SELECT id, nama, nik FROM salesmen
      ) AS us ON sp.salesmen_id = us.id
      LEFT JOIN
      (
        SELECT id, Cabang FROM tbidcabang
      ) AS cb ON sp.branch_id = cb.id
      LEFT JOIN
      (
       SELECT SUM(jumlah) AS jumlah, cabang_id, nopo, jenisbrgdisc FROM tblaporancabang WHERE fiscal_month = '#{Date.yesterday.month}'
       AND fiscal_year = '#{Date.yesterday.year}' AND
       tipecust = 'RETAIL' AND bonus = '-' AND
       kodejenis IN ('KM','DV','HB','KB') AND orty = 'SO'
      ) AS lc ON lc.nopo = us.nik AND lc.jenisbrgdisc = sp.brand AND lc.cabang_id = sp.branch_id
    ")
  end

  def self.retail_productivity_all_branch
    self.find_by_sql("SELECT cb.Cabang, lc.cabang_id, lc.jenisbrgdisc, lc.jumlah, lc.salesman, lc.tanggalsj, sp.salesmen, (lc.jumlah/(sp.salesmen*8)) AS prod FROM
    (
     SELECT cabang_id, jenisbrgdisc, SUM(jumlah) AS jumlah, salesman, tanggalsj FROM tblaporancabang WHERE
     tanggalsj BETWEEN '#{1.week.ago.to_date}' AND
     '#{Date.yesterday.to_date}' AND kodejenis IN ('KM','DV','HB','KB') AND
     bonus = '-' AND tipecust = 'RETAIL'
     GROUP BY tanggalsj, cabang_id, jenisbrgdisc
    ) AS lc
    LEFT JOIN
    (
      SELECT COUNT(salesmen_id) AS salesmen, branch_id, brand,
      date FROM sales_productivities GROUP BY brand, branch_id, date
    ) AS sp ON sp.date = lc.tanggalsj AND sp.branch_id = lc.cabang_id AND sp.brand = lc.jenisbrgdisc
    LEFT JOIN
    (
      SELECT id, Cabang FROM tbidcabang
    ) AS cb ON cb.id = lc.cabang_id
    ")
  end
end