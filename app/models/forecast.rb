class Forecast < ActiveRecord::Base
  def self.calculate_rkm_sales(week, year, address)
    date = Date.commercial(year.to_i, week.to_i).to_date
    find_by_sql("
      SELECT * FROM(
      SELECT cab.Cabang AS cabang, f1.address_number AS address_number, IFNULL(fw.sales_name, tl.salesman) AS sales_name, IFNULL(fw.week, tl.week) AS week,
      f1.item_number AS item_number, IFNULL(fw.size, tl.lebar) AS size, IFNULL(fw.brand, tl.jenisbrgdisc) AS brand,
      IFNULL(fw.segment2_name, tl.namaartikel) AS segment2_name, IFNULL(fw.segment3_name, tl.namakain) AS segment3_name,
      IFNULL(fw.quantity, 0) AS target_penjualan, IFNULL(tl.jumlah,0) AS jumlah_penjualan,
      IFNULL(st.onhand, 0) AS stock, f1.branch, (IFNULL(fw.quantity, 0)+IFNULL(rh.quantity,0)) AS total_target, rh.quantity AS sisa FROM
      (
        SELECT item_number, address_number, branch FROM forecast_weeklies WHERE
        WEEK = '#{week}' AND YEAR = '#{year}' AND address_number = '#{address}' GROUP BY item_number, branch, brand

        UNION

        SELECT DISTINCT(kodebrg), nopo, area_id FROM dbmarketing.tblaporancabang
        WHERE tanggalsj BETWEEN '#{date}' AND '#{date+6}' AND nopo = '#{address}'
        AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO')  GROUP BY area_id, kodebrg, jenisbrgdisc
      ) f1
      LEFT JOIN
      (
        SELECT * FROM forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{year}' GROUP BY branch, brand, address_number, item_number
      ) fw ON fw.branch = f1.branch AND fw.address_number = f1.address_number AND fw.item_number = f1.item_number
      LEFT JOIN
      (
        SELECT area_id, kodebrg, SUM(jumlah) AS jumlah, nopo, salesman, lebar, jenisbrgdisc, namaartikel, namakain, SUM(jumlah) AS jml, WEEK
        FROM dbmarketing.tblaporancabang
        WHERE tanggalsj BETWEEN '#{date}' AND '#{date+6}' AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO')
        AND ketppb NOT LIKE '%D' GROUP BY area_id, kodebrg, nopo
      ) tl ON tl.area_id = f1.branch AND tl.kodebrg = f1.item_number AND tl.nopo = f1.address_number
      LEFT JOIN
      (
        SELECT item_number, address_number, WEEK, quantity FROM rkm_histories WHERE week = '#{week.to_i-1}'
      ) rh ON rh.item_number = f1.item_number AND rh.address_number = f1.address_number
      LEFT JOIN
      (
        SELECT item_number, branch_code, SUM(onhand) AS onhand FROM warehouse.F41021_STOCK WHERE DATE(created_at) = '#{Date.today.to_date}'
        GROUP BY item_number, branch_code
      ) st ON st.item_number = f1.item_number AND st.branch_code = f1.branch
      LEFT JOIN
      (
        SELECT * FROM dbmarketing.tbidcabang
      ) cab ON cab.id = f1.branch
      ORDER BY IFNULL(fw.sales_name, tl.salesman) ASC, IFNULL(tl.jumlah,0) DESC
      ) au WHERE au.week is not null
    ")
  end

  def self.calculate_rkm_recap_admin(week, year, brand)
    date = Date.commercial(year.to_i, week.to_i).to_date
    find_by_sql("
      SELECT * FROM(
      SELECT cab.Cabang AS cabang, f1.address_number AS address_number, IFNULL(fw.sales_name, tl.salesman) AS sales_name,
      IFNULL(fw.brand, tl.jenisbrgdisc) AS brand,
      IFNULL(SUM(fw.quantity), 0) AS target_penjualan, IFNULL(SUM(tl.jumlah),0) AS jumlah_penjualan,
      f1.branch, (IFNULL(SUM(fw.quantity), 0)+IFNULL(SUM(rh.quantity),0)) AS total_target, rh.quantity AS sisa FROM
      (
        SELECT item_number, address_number, branch FROM forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{year}'
        GROUP BY address_number, item_number, branch

        UNION

        SELECT DISTINCT(kodebrg), nopo, area_id FROM dbmarketing.tblaporancabang
        WHERE tanggalsj BETWEEN '#{date}' AND '#{date+6}' AND nopo IS NOT NULL
        AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO') GROUP BY area_id, kodebrg, nopo
      ) f1
      LEFT JOIN
      (
        SELECT * FROM forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{year}' GROUP BY branch, brand, address_number, item_number
      ) fw ON fw.branch = f1.branch AND fw.address_number = f1.address_number AND fw.item_number = f1.item_number
      LEFT JOIN
      (
        SELECT area_id, kodebrg, SUM(jumlah) AS jumlah, nopo, salesman, lebar, jenisbrgdisc, namaartikel, namakain, SUM(jumlah) AS jml, WEEK
        FROM dbmarketing.tblaporancabang
        WHERE tanggalsj BETWEEN '#{date}' AND '#{date+6}' AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO')
        AND ketppb NOT LIKE '%D'
        GROUP BY area_id, kodebrg, nopo
      ) tl ON tl.area_id = f1.branch AND tl.kodebrg = f1.item_number AND tl.nopo = f1.address_number
      LEFT JOIN
      (
        SELECT item_number, address_number, WEEK, quantity FROM rkm_histories WHERE week = '#{week.to_i-1}'
      ) rh ON rh.item_number = f1.item_number AND rh.address_number = f1.address_number
      LEFT JOIN
      (
        SELECT * FROM dbmarketing.tbidcabang
      ) cab ON cab.id = f1.branch
      GROUP BY cab.Cabang, f1.address_number, IFNULL(fw.brand, tl.jenisbrgdisc)
      ORDER BY IFNULL(fw.brand, tl.jenisbrgdisc), IFNULL(fw.sales_name, tl.salesman) ASC, IFNULL(SUM(tl.jumlah),0) DESC
      ) au WHERE au.brand IS NOT null
    ")
  end

  def self.calculate_rkm_admin(week, year, brand)
    date = Date.commercial(year.to_i, week.to_i).to_date
    find_by_sql("
      SELECT * FROM(
      SELECT cab.Cabang AS cabang, f1.address_number AS address_number, IFNULL(fw.sales_name, tl.salesman) AS sales_name, IFNULL(fw.week, tl.week) AS week,
      f1.item_number AS item_number, IFNULL(fw.size, tl.lebar) AS size, IFNULL(fw.brand, tl.jenisbrgdisc) AS brand,
      IFNULL(fw.segment2_name, tl.namaartikel) AS segment2_name, IFNULL(fw.segment3_name, tl.namakain) AS segment3_name,
      IFNULL(fw.quantity, 0) AS target_penjualan, IFNULL(tl.jumlah,0) AS jumlah_penjualan, IFNULL(st.onhand, 0) AS stock,
      f1.branch, (IFNULL(fw.quantity, 0)+IFNULL(rh.quantity,0)) AS total_target, rh.quantity AS sisa FROM
      (
        SELECT item_number, address_number, branch FROM forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{year}'
        AND brand = '#{brand}' GROUP BY address_number, item_number, branch

        UNION

        SELECT DISTINCT(kodebrg), nopo, area_id FROM dbmarketing.tblaporancabang
        WHERE tanggalsj BETWEEN '#{date}' AND '#{date+6}' AND nopo IS NOT NULL AND jenisbrgdisc = '#{brand}'
        AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO') GROUP BY area_id, kodebrg, nopo
      ) f1
      LEFT JOIN
      (
        SELECT * FROM forecast_weeklies WHERE WEEK = '#{week}' AND YEAR = '#{year}' GROUP BY branch, brand, address_number, item_number
      ) fw ON fw.branch = f1.branch AND fw.address_number = f1.address_number AND fw.item_number = f1.item_number
      LEFT JOIN
      (
        SELECT area_id, kodebrg, SUM(jumlah) AS jumlah, nopo, salesman, lebar, jenisbrgdisc, namaartikel, namakain, SUM(jumlah) AS jml, WEEK
        FROM dbmarketing.tblaporancabang
        WHERE tanggalsj BETWEEN '#{date}' AND '#{date+6}' AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO')
        AND ketppb NOT LIKE '%D'
        GROUP BY area_id, kodebrg, nopo
      ) tl ON tl.area_id = f1.branch AND tl.kodebrg = f1.item_number AND tl.nopo = f1.address_number
      LEFT JOIN
      (
        SELECT item_number, address_number, WEEK, quantity FROM rkm_histories WHERE week = '#{week.to_i-1}'
      ) rh ON rh.item_number = f1.item_number AND rh.address_number = f1.address_number
      LEFT JOIN
      (
        SELECT item_number, branch_code, SUM(onhand) AS onhand FROM warehouse.F41021_STOCK WHERE DATE(created_at) = '#{Date.today.to_date}'
        GROUP BY item_number, branch_code
      ) st ON st.item_number = f1.item_number AND st.branch_code = f1.branch
      LEFT JOIN
      (
        SELECT * FROM dbmarketing.tbidcabang
      ) cab ON cab.id = f1.branch
      ORDER BY IFNULL(fw.sales_name, tl.salesman) ASC, IFNULL(tl.jumlah,0) DESC
      ) au WHERE au.week is not null
    ")
  end

  def self.calculate_rkm(week, year, area, brand)
    date = Date.commercial(year.to_i, week.to_i).to_date
    find_by_sql("
      SELECT * FROM(
      SELECT cab.Cabang AS cabang, f1.address_number AS address_number, IFNULL(fw.sales_name, tl.salesman) AS sales_name, IFNULL(fw.week, tl.week) AS week,
      f1.item_number AS item_number, IFNULL(fw.size, tl.lebar) AS size, IFNULL(fw.brand, tl.jenisbrgdisc) AS brand,
      IFNULL(fw.segment2_name, tl.namaartikel) AS segment2_name, IFNULL(fw.segment3_name, tl.namakain) AS segment3_name,
      IFNULL(fw.quantity, 0) AS target_penjualan, IFNULL(tl.jumlah,0) AS jumlah_penjualan,
      IFNULL(st.onhand, 0) AS stock, f1.branch, (IFNULL(fw.quantity, 0)+IFNULL(rh.quantity,0)) AS total_target, rh.quantity AS sisa FROM
      (
        SELECT item_number, address_number, branch FROM forecast_weeklies WHERE
        branch = '#{area}' AND WEEK = '#{week}' AND YEAR = '#{year}'
        AND brand = '#{brand}' GROUP BY address_number, item_number, branch

        UNION

        SELECT DISTINCT(kodebrg), nopo, area_id FROM dbmarketing.tblaporancabang
        WHERE tanggalsj BETWEEN '#{date}' AND '#{date+6}' AND area_id = '#{area}' AND nopo IS NOT NULL AND jenisbrgdisc = '#{brand}'
        AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO') GROUP BY area_id, kodebrg, nopo
      ) f1
      LEFT JOIN
      (
        SELECT * FROM forecast_weeklies WHERE branch = '#{area}' AND WEEK = '#{week}' AND YEAR = '#{year}' GROUP BY branch, brand, address_number, item_number
      ) fw ON fw.branch = f1.branch AND fw.address_number = f1.address_number AND fw.item_number = f1.item_number
      LEFT JOIN
      (
        SELECT area_id, kodebrg, SUM(jumlah) AS jumlah, nopo, salesman, lebar, jenisbrgdisc, namaartikel, namakain, SUM(jumlah) AS jml, WEEK
        FROM dbmarketing.tblaporancabang
        WHERE tanggalsj BETWEEN '#{date}' AND '#{date+6}' AND tipecust = 'RETAIL' AND orty IN ('RI', 'RO')
        AND area_id = '#{area}' AND ketppb NOT LIKE '%D' GROUP BY area_id, kodebrg, nopo
      ) tl ON tl.area_id = f1.branch AND tl.kodebrg = f1.item_number AND tl.nopo = f1.address_number
      LEFT JOIN
      (
        SELECT item_number, address_number, WEEK, quantity FROM rkm_histories WHERE week = '#{week.to_i-1}'
      ) rh ON rh.item_number = f1.item_number AND rh.address_number = f1.address_number
      LEFT JOIN
      (
        SELECT item_number, branch_code, SUM(onhand) AS onhand FROM warehouse.F41021_STOCK WHERE DATE(created_at) = '#{Date.today.to_date}'
        GROUP BY item_number, branch_code
      ) st ON st.item_number = f1.item_number AND st.branch_code = f1.branch
      LEFT JOIN
      (
        SELECT * FROM dbmarketing.tbidcabang
      ) cab ON cab.id = f1.branch
      ORDER BY IFNULL(fw.sales_name, tl.salesman) ASC, IFNULL(tl.jumlah,0) DESC
      ) au WHERE au.week is not null
    ")
  end

  def self.calculation_forecast_year(start_date, end_date, area, brand)
    self.find_by_sql("
      SELECT f1.namaartikel, f.description, f.segment1, f.segment2_name, f.brand, f.month, f.year,
      lp.namabrg, a.area, f.branch, f.segment2_name, f.segment3_name,
      lp.kodejenis, lp.lebar, f.size, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv,
      lp.namaartikel, lp.namakain, f2.qty_last, lp2.jml_last, ((lp2.jml_last/f2.qty_last)*100) AS acv2
      FROM
      (
        SELECT DISTINCT(kodebrg), namaartikel, kodekain, namakain FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}'
        GROUP BY kodebrg

        UNION ALL

        SELECT DISTINCT(item_number), segment2_name, segment3, segment3_name FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND branch = '#{area}' AND brand = '#{brand}' GROUP BY item_number
      ) AS f1
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jumlah, kodebrg, namabrg, kodejenis, namaartikel, namakain, area_id, lebar,
        fiscal_month, fiscal_year, kodeartikel, kodekain FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}'
        GROUP BY kodebrg, area_id, jenisbrgdisc
      ) AS lp ON lp.kodebrg = f1.kodebrg
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jml_last, kodebrg, namabrg, kodejenis, namaartikel, namakain, area_id, lebar,
        fiscal_month, fiscal_year, kodeartikel, kodekain FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date.last_year}'
        AND '#{end_date.to_date.last_year}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}'
        GROUP BY kodebrg, area_id, jenisbrgdisc
      ) AS lp2 ON lp2.kodebrg = f1.kodebrg
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2, segment2_name,
        segment3_name, size, SUM(quantity) AS quantity, segment3 FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}' AND branch = '#{area}' GROUP BY item_number
      ) AS f ON f.item_number = f1.kodebrg
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2, segment2_name,
        segment3_name, size, SUM(quantity) AS qty_last, segment3 FROM
        forecasts WHERE month BETWEEN '#{start_date.to_date.last_year.month}' AND '#{end_date.to_date.last_year.month}'
        AND year BETWEEN '#{start_date.to_date.last_year.year}' AND '#{end_date.to_date.last_year.year}' AND branch = '#{area}' GROUP BY item_number
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
      forecast = find_by(brand: row["brand"], address_number: row["address_number"].to_i, item_number: row["item_number"].strip, branch: row["branch"],
      month: row["month"], year: row["year"]) || new
      unless row["quantity"].nil? || row["quantity"] == 0
        if forecast.id.nil?
          item = JdeItemMaster.get_desc_forecast(row["item_number"])
          sales_name = Jde.get_sales_rkb(row["address_number"].to_i)
          row["segment1"] = item.nil? ? 0 : item.imseg1.strip
          row["segment2"] = item.nil? ? 0 : item.imseg2.strip
          row["segment3"] = item.nil? ? 0 : item.imseg3.strip
          row["segment2_name"] = item.nil? ? 0 : JdeUdc.artikel_udc(item.imseg2.strip)
          row["segment3_name"] = item.nil? ? 0 : JdeUdc.kain_udc(item.imseg3.strip)
          row["size"] = item.nil? ? 0 : item.imseg6.strip
          row["description"] = item.nil? ? 'UNLISTED ITEM NUMBER' : (item.imdsc1.strip + ' ' + item.imdsc2.strip)
          row["planner"] = '-'
          row["sales_name"] = sales_name.nil? ? ' ' : sales_name.abalph.strip
        forecast.attributes = row.to_hash
        else
          forecast["quantity"] = row["quantity"]
        end
      forecast.save!
      end
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
              tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
              ('KM', 'DV', 'HB', 'KB', 'SB', 'SA', 'ST')  AND tanggalsj BETWEEN '#{start_date.to_date}'
              AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc NOT LIKE 'CLASSIC'

              UNION ALL

              SELECT DISTINCT(item_number) FROM
              forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
              '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}'
              AND '#{end_date.to_date.year}' AND branch = '#{area}'
            ) AS f1
            LEFT JOIN
            (
              SELECT SUM(jumlah) AS jumlah, jenisbrgdisc, kodebrg, namabrg, area_id, fiscal_month, fiscal_year FROM
              tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
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
              forecasts WHERE branch = '#{area}' AND MONTH BETWEEN '#{start_date.to_date.month}' AND
              '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
              GROUP BY item_number
            ) AS f ON f.item_number = f1.kodebrg
            LEFT JOIN
            (
              SELECT * FROM areas
            ) AS a ON f.branch = a.id
      GROUP BY f1.kodebrg
      ) AS oa GROUP BY oa.jenisbrgdisc
    ")
  end

  def self.calculation_forecasts_salesman(start_date, end_date, area, brand)
    self.find_by_sql("
      SELECT f1.kodebrg, f.description, f.segment1, f.segment2_name, f.brand, f.month, f.year,
      lp.namabrg, a.area, f.branch, f.segment2_name, f.segment3_name, f.sales_name, f.address_number,
      lp.kodejenis, lp.lebar, f.size, f.quantity, lp.jumlah, ((lp.jumlah/f.quantity)*100) AS acv, lp.namaartikel, lp.namakain,
      IFNULL(s.onhand, 0) AS onhand,
      IFNULL(ib.qty_buf, 0) AS qty_buf FROM
      (
        SELECT DISTINCT(kodebrg), nopo FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}' AND orty IN ('RI', 'RO')

        UNION ALL

        SELECT DISTINCT(item_number), address_number FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND branch = '#{area}' AND brand = '#{brand}'
      ) AS f1
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jumlah, kodebrg, namabrg, kodejenis, namaartikel, namakain, area_id, lebar,
        fiscal_month, fiscal_year, nopo, salesman FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}' AND orty IN ('RI', 'RO')
        GROUP BY kodebrg, area_id, jenisbrgdisc, nopo
      ) AS lp ON lp.kodebrg = f1.kodebrg AND lp.nopo = f1.nopo
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
        segment3_name, size, SUM(quantity) AS quantity, address_number, sales_name FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND branch = '#{area}' GROUP BY item_number, address_number
      ) AS f ON f.item_number = f1.kodebrg AND f.branch = '#{area}' AND f.address_number = f1.nopo
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
      GROUP BY f1.kodebrg, f1.nopo
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
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}' AND orty IN ('RI', 'RO')

        UNION ALL

        SELECT DISTINCT(item_number) FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND branch = '#{area}' AND brand = '#{brand}'
      ) AS f1
      LEFT JOIN
      (
        SELECT SUM(jumlah) AS jumlah, kodebrg, namabrg, kodejenis, namaartikel, namakain, area_id, lebar,
        fiscal_month, fiscal_year FROM
        tblaporancabang WHERE tipecust = 'RETAIL' AND kodejenis IN
        ('KM', 'DV', 'HB', 'KB', 'SB', 'SA')  AND tanggalsj BETWEEN '#{start_date.to_date}'
        AND '#{end_date.to_date}' AND area_id = '#{area}' AND jenisbrgdisc = '#{brand}' AND orty IN ('RI', 'RO')
        GROUP BY kodebrg, area_id, jenisbrgdisc
      ) AS lp ON lp.kodebrg = f1.kodebrg
      LEFT JOIN
      (
        SELECT description, brand, branch, MONTH, YEAR, item_number, segment1, segment2_name,
        segment3_name, size, SUM(quantity) AS quantity FROM
        forecasts WHERE MONTH BETWEEN '#{start_date.to_date.month}' AND
        '#{end_date.to_date.month}' AND YEAR BETWEEN '#{start_date.to_date.year}' AND '#{end_date.to_date.year}'
        AND branch = '#{area}' GROUP BY item_number
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
        tblaporancabang WHERE tipecust = '#{id_img}' AND kodejenis IN
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
        tblaporancabang WHERE tipecust = '#{id_img}' AND kodejenis IN
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
