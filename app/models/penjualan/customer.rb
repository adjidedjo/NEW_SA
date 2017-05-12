class Penjualan::Customer < Penjualan::Sale
  def self.reporting_customers(month, year, branch)
    find_by_sql("SELECT customer, kode_customer,
      SUM(CASE WHEN jenisbrgdisc = 'ELITE' THEN harganetto1 END) elite,
      SUM(CASE WHEN jenisbrgdisc = 'SERENITY' THEN harganetto1 END) serenity,
      SUM(CASE WHEN jenisbrgdisc = 'LADY' THEN harganetto1 END) lady,
      SUM(CASE WHEN jenisbrgdisc = 'ROYAL' THEN harganetto1 END) royal
      FROM tblaporancabang WHERE fiscal_month = '#{month}'
      AND fiscal_year = '#{year}'
      AND cabang_id != 1 AND cabang_id != 50
      AND cabang_id = '#{branch}'AND
      tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN ('KM', 'DV', 'HB', 'KB')
      GROUP BY kode_customer
    ")
  end
end