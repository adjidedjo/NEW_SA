class Forecast < ActiveRecord::Base
  
  def self.update_master_forecast
    self.all.each do |e|
      item = ItemMaster.where(item_number: e.item_number).first
      a = item.nil? ? 0 : item.segment1
      e.update_attributes!(segment1: a)
    end
  end
  
  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      forecast = find_by(brand: row["brand"], item_number: row["item_number"], branch: row["branch"], 
      month: row["month"], year: row["year"]) || new
      if forecast["id"].nil?
        item = ItemMaster.where(item_number: row["item_number"]).first
        row["segment1"] = item.nil? ? 0 : item.segment1
        row["segment2"] = item.nil? ? 0 : item.segment2
        row["segment3"] = item.nil? ? 0 : item.segment3
        row["segment2_name"] = item.nil? ? 0 : JdeUdc.artikel_udc(item.segment2)
        row["segment3_name"] = item.nil? ? 0 : JdeUdc.kain_udc(item.segment3)
        row["size"] = item.nil? ? 0 : item.segment6
        forecast.attributes = row.to_hash
      else
        forecast["quantity"] = row["quantity"]
      end
      forecast.save!
    end
  end

  def self.calculation_forecasts_by_branch(start_date, end_date, area)
    self.find_by_sql("
      SELECT f.segment1, f.brand, f.month, f.year, a.area, f.branch, f.segment2_name, f.segment3_name,
      f.size, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv FROM
      (
        SELECT brand, branch, MONTH, YEAR, item_number, segment1, segment2_name, 
        segment3_name, size, SUM(quantity) AS quantity FROM
        forecasts WHERE branch = '#{area}' AND month = '#{start_date.to_date.month}'
        AND year = '#{start_date.to_date.year}' GROUP BY brand
      ) AS f
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jumlah, jenisbrgdisc, area_id, fiscal_month, fiscal_year FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA') AND orty IN ('SO', 'ZO') AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}'
        GROUP BY area_id, jenisbrgdisc, fiscal_month, fiscal_year
      ) AS lp ON f.brand = lp.jenisbrgdisc
        AND f.branch = lp.area_id
      LEFT JOIN
      (
        SELECT * FROM areas
      ) AS a ON f.branch = a.id
    ")
  end

  def self.calculation_forecasts(start_date, end_date, area, brand)
    self.find_by_sql("
      SELECT f.segment1, f.brand, f.month, f.year, lp.namabrg, a.area, f.branch, f.segment2_name, f.segment3_name,
      f.size, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv, s.onhand, ib.qty_buf FROM
      (
        SELECT brand, branch, MONTH, YEAR, item_number, segment1, segment2_name, 
        segment3_name, size, quantity FROM
        forecasts WHERE branch = '#{area}' AND month = '#{start_date.to_date.month}'
        AND year = '#{start_date.to_date.year}' AND brand = '#{brand}'
      ) AS f
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jumlah, kodebrg, namabrg, area_id, fiscal_month, fiscal_year FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA') AND orty IN ('SO', 'ZO') AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}'
        GROUP BY kodebrg, area_id, jenisbrgdisc, fiscal_month, fiscal_year
      ) AS lp ON f.item_number = lp.kodebrg
        AND f.branch = lp.area_id
      LEFT JOIN
      (
        SELECT onhand, item_number, area_id, short_item FROM stocks
      ) AS s ON s.item_number = f.item_number AND s.area_id = f.branch
      LEFT JOIN
      (
        SELECT quantity AS qty_buf, short_item, area FROM item_branches
      ) AS ib ON s.short_item = ib.short_item AND s.area_id = ib.area
      LEFT JOIN
      (
        SELECT * FROM areas
      ) AS a ON f.branch = a.id
    ")
  end

end