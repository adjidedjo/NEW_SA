class Forecast < ActiveRecord::Base
  def self.calculation_forecast_year(start_date, end_date, area, brand)
    self.find_by_sql("
      SELECT f1.namaartikel, f.description, f.segment1, f.segment2_name, f.brand, f.month, f.year,
      lp.namabrg, a.area, f.branch, f.segment2_name, f.segment3_name,
      lp.kodejenis, lp.lebar, f.size, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv,
      lp.namaartikel, lp.namakain, f2.qty_last, lp2.jml_last, ((lp2.jml_last/f2.qty_last)*100) AS acv2
      FROM
      (
        SELECT DISTINCT(kodebrg), namaartikel, kodekain, namakain FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}'
        GROUP BY kodebrg

        UNION ALL

        SELECT DISTINCT(item_number), segment2_name, segment3, segment3_name FROM
        forecasts WHERE MONTH = '#{end_date.to_date.month}' AND YEAR = '#{end_date.to_date.year}'
        AND branch = '#{area}' AND brand = '#{brand}' GROUP BY item_number
      ) AS f1
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jumlah, kodebrg, namabrg, kodejenis, namaartikel, namakain, area_id, lebar,
        fiscal_month, fiscal_year, kodeartikel, kodekain FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}'
        GROUP BY kodebrg, area_id, jenisbrgdisc, fiscal_month, fiscal_year
      ) AS lp ON lp.kodebrg = f1.kodebrg
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jml_last, kodebrg, namabrg, kodejenis, namaartikel, namakain, area_id, lebar,
        fiscal_month, fiscal_year, kodeartikel, kodekain FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date.last_year}'
        AND '#{end_date.to_date.last_year}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}'
        GROUP BY kodebrg, area_id, jenisbrgdisc, fiscal_month, fiscal_year
      ) AS lp2 ON lp2.kodebrg = f1.kodebrg
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2, segment2_name,
        segment3_name, size, SUM(quantity) AS quantity, segment3 FROM
        forecasts WHERE month = '#{start_date.to_date.month}'
        AND year = '#{start_date.to_date.year}' AND branch = '#{area}' GROUP BY item_number
      ) AS f ON f.item_number = f1.kodebrg
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2, segment2_name,
        segment3_name, size, SUM(quantity) AS qty_last, segment3 FROM
        forecasts WHERE month = '#{start_date.to_date.last_year.month}'
        AND year = '#{start_date.to_date.last_year.year}' AND branch = '#{area}' GROUP BY item_number
      ) AS f2 ON f2.item_number = f1.kodebrg
      LEFT JOIN
      (
        SELECT * FROM areas
      ) AS a ON IFNULL(lp.area_id, f.branch) = a.id
      WHERE lp.jumlah > 0 OR f.quantity > 0
      GROUP BY f1.kodebrg
    ")
  end

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
      forecast = find_by(brand: row["brand"], item_number: row["item_number"].strip, branch: row["branch"],
      month: row["month"], year: row["year"]) || new
      if forecast.id.nil?
        item = JdeItemMaster.get_desc_forecast(row["item_number"])
        row["segment1"] = item.nil? ? 0 : item.imseg1.strip
        row["segment2"] = item.nil? ? 0 : item.imseg2.strip
        row["segment3"] = item.nil? ? 0 : item.imseg3.strip
        row["segment2_name"] = item.nil? ? 0 : JdeUdc.artikel_udc(item.imseg2.strip)
        row["segment3_name"] = item.nil? ? 0 : JdeUdc.kain_udc(item.imseg3.strip)
        row["size"] = item.nil? ? 0 : item.imseg6.strip
        row["description"] = item.nil? ? 'UNLISTED ITEM NUMBER' : (item.imdsc1.strip + ' ' + item.imdsc2.strip)
      forecast.attributes = row.to_hash
      else
        forecast["quantity"] = row["quantity"]
      end
      forecast.save!
    end
  end

  def self.calculation_forecasts_by_branch(start_date, end_date, area)
    self.find_by_sql("
      SELECT oa.jenisbrgdisc AS brand, SUM(oa.quantity) AS quantity, SUM(oa.jumlah) AS jumlah,
      SUM(oa.acv) AS acv, SUM(oa.todate) AS todate, SUM(IFNULL(equal_sales,0)) AS equal_sales,
      SUM(IFNULL(more_sales,0)) AS more_sales, SUM(IFNULL(less_sales,0)) AS less_sales,
      SUM(IFNULL(more_sales_for_non,0)) AS msfn FROM
      (
            SELECT lp.kodebrg, f.todate, IFNULL(lp.jenisbrgdisc, f.brand) AS jenisbrgdisc, lp.namabrg, a.area,
            f.branch, f.size, f.quantity, lp.jumlah, ABS((IFNULL(lp.jumlah,0)-IFNULL(f.todate,0))) AS acv,
            CASE WHEN IFNULL(lp.jumlah,0) = IFNULL(f.todate, 0) THEN lp.jumlah END AS equal_sales,
            CASE WHEN IFNULL(lp.jumlah,0) > IFNULL(f.todate,0) THEN f.todate END AS more_sales,
            CASE WHEN IFNULL(lp.jumlah,0) < IFNULL(f.todate,0) THEN lp.jumlah END AS less_sales,
            CASE WHEN IFNULL(lp.jumlah,0) > IFNULL(f.todate,0) THEN
            (IFNULL(lp.jumlah,0) - IFNULL(f.todate,0)) END AS more_sales_for_non
            FROM
            (
              SELECT DISTINCT(kodebrg) FROM
              tblaporancabang WHERE tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN
              ('KM', 'DV', 'HB', 'KB', 'SB', 'SA', 'ST')  AND tanggalsj BETWEEN '#{start_date.to_date}'
              AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc NOT LIKE 'CLASSIC'

              UNION ALL

              SELECT DISTINCT(item_number) FROM
              forecasts WHERE MONTH = '#{end_date.to_date.month}' AND YEAR = '#{end_date.to_date.year}'
              AND branch = '#{area}'
            ) AS f1
            LEFT JOIN
            (
              SELECT SUM(jumlah) AS jumlah, jenisbrgdisc, kodebrg, namabrg, area_id, fiscal_month, fiscal_year FROM
              tblaporancabang WHERE tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN
              ('KM', 'DV', 'HB', 'KB', 'SB', 'SA', 'ST')  AND tanggalsj
              BETWEEN '#{start_date.to_date}' AND '#{end_date.to_date}' AND area_id = '#{area}'
              AND jenisbrgdisc NOT LIKE 'CLASSIC'
              GROUP BY area_id, kodebrg
            ) AS lp ON lp.kodebrg = f1.kodebrg
            LEFT JOIN
            (
              SELECT brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
              segment3_name, size, SUM(quantity) AS quantity,
              ROUND((SUM(quantity)/DAY(LAST_DAY('#{end_date.to_date}')))*DAY('#{end_date.to_date}')) AS todate FROM
              forecasts WHERE branch = '#{area}' AND MONTH = '#{end_date.to_date.month}'
              AND YEAR = '#{end_date.to_date.year}' GROUP BY item_number
            ) AS f ON f.item_number = f1.kodebrg
            LEFT JOIN
            (
              SELECT * FROM areas
            ) AS a ON f.branch = a.id
      GROUP BY f1.kodebrg
      ) AS oa GROUP BY oa.jenisbrgdisc
    ")
  end

  def self.calculation_forecasts(start_date, end_date, area, brand)
    self.find_by_sql("
      SELECT f1.kodebrg, f.description, f.segment1, f.segment2_name, f.brand, f.month, f.year,
      lp.namabrg, a.area, f.branch, f.segment2_name, f.segment3_name,
      lp.kodejenis, lp.lebar, f.size, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv, lp.namaartikel, lp.namakain,
      IFNULL(s.onhand, 0) AS onhand,
      IFNULL(ib.qty_buf, 0) AS qty_buf FROM
      (
        SELECT DISTINCT(kodebrg) FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}'

        UNION ALL

        SELECT DISTINCT(item_number) FROM
        forecasts WHERE MONTH = '#{end_date.to_date.month}' AND YEAR = '#{end_date.to_date.year}'
        AND branch = '#{area}' AND brand = '#{brand}'
      ) AS f1
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jumlah, kodebrg, namabrg, kodejenis, namaartikel, namakain, area_id, lebar,
        fiscal_month, fiscal_year, area_id FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND bonus = '-' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}'
        GROUP BY kodebrg, area_id, jenisbrgdisc, fiscal_month, fiscal_year
      ) AS lp ON lp.kodebrg = f1.kodebrg
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
        segment3_name, size, SUM(quantity) AS quantity FROM
        forecasts WHERE month = '#{start_date.to_date.month}'
        AND year = '#{start_date.to_date.year}' AND branch = '#{area}' GROUP BY item_number
      ) AS f ON f.item_number = f1.kodebrg AND f.branch = '#{area}'
      LEFT JOIN
      (
        SELECT onhand, item_number, area_id, short_item FROM stocks WHERE status = 'N'
      ) AS s ON s.item_number = f1.kodebrg AND s.area_id = #{area}
      LEFT JOIN
      (
        SELECT quantity AS qty_buf, short_item, area FROM item_branches
      ) AS ib ON s.short_item = ib.short_item AND s.area_id = ib.area
      LEFT JOIN
      (
        SELECT * FROM areas
      ) AS a ON IFNULL(lp.area_id, f.branch) = a.id
      GROUP BY f1.kodebrg
    ")
  end

  def self.calculation_direct_forecast(start_date, end_date, area)
    id_img = area == 100 ? "DIRECT" : "MODERN"
    self.find_by_sql("
      SELECT f1.kodebrg, f.description, f.segment1, f.segment2_name, f.brand, f.month, f.year,
      lp.namabrg, f.branch, f.segment2_name, f.segment3_name,
      lp.kodejenis, lp.lebar, f.size, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv,
      lp.namaartikel, lp.namakain FROM
      (
        SELECT DISTINCT(kodebrg) FROM
        tblaporancabang WHERE tipecust = '#{id_img}' AND bonus = '-' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}'

        UNION ALL

        SELECT DISTINCT(item_number) FROM
        forecasts WHERE MONTH = '#{end_date.to_date.month}' AND YEAR = '#{end_date.to_date.year}'
        AND branch = '#{area}'
      ) AS f1
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jumlah, kodebrg, namabrg, kodejenis, namaartikel, namakain, area_id, lebar,
        fiscal_month, fiscal_year FROM
        tblaporancabang WHERE tipecust = '#{id_img}' AND bonus = '-' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}'
        GROUP BY kodebrg, jenisbrgdisc, fiscal_month, fiscal_year
      ) AS lp ON lp.kodebrg = f1.kodebrg
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
        segment3_name, size, SUM(quantity) AS quantity FROM
        forecasts WHERE month = '#{start_date.to_date.month}'
        AND year = '#{start_date.to_date.year}' AND branch = '#{area}' GROUP BY item_number
      ) AS f ON f.item_number = f1.kodebrg
      GROUP BY f1.kodebrg
    ")
  end

end