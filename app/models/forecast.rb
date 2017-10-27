class Forecast < ActiveRecord::Base
  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      forecast = find_by(brand: row["brand"], item_number: row["item_number"], branch: row["branch"], 
      month: row["month"], year: row["year"]) || new
      if forecast["id"].nil?
      forecast.attributes = row.to_hash
      else
        forecast["quantity"] = row["quantity"]
      end
      forecast.save!
    end
  end

  def self.calculation_forecasts(month, year, area)
    self.find_by_sql("
      SELECT f.brand, f.month, f.year, lp.namabrg, a.area, f.branch,
      f.item_number, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv FROM
      (
        SELECT brand, branch, MONTH, YEAR, item_number, quantity FROM
        forecasts WHERE branch = '#{area}' AND month = '#{month}'
        AND year = '#{year}'
      ) AS f
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jumlah, kodebrg, namabrg, area_id, fiscal_month, fiscal_year FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')
        GROUP BY kodebrg, area_id, jenisbrgdisc, fiscal_month, fiscal_year
      ) AS lp ON f.item_number = lp.kodebrg AND f.month = lp.fiscal_month AND f.year = lp.fiscal_year
        AND f.branch = lp.area_id
      LEFT JOIN
      (
        SELECT * FROM areas
      ) AS a ON f.branch = a.id
    ")
  end

end