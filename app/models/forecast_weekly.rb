class ForecastWeekly < ActiveRecord::Base
  
  def self.import_weekly(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      forecast = find_by(brand: row["brand"].upcase, address_number: row["address_number"], 
      item_number: row["item_number"].strip, branch: row["branch"],
      week: row["week"], year: row["year"]) || ForecastWeekly.new
      unless row["quantity"].nil? || row["quantity"] == 0
        if forecast.id.nil?
          item = JdeItemMaster.get_desc_forecast(row["item_number"])
          sales_name = Jde.get_sales_rkb(row["address_number"])
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
  
end