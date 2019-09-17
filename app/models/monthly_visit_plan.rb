class MonthlyVisitPlan < ActiveRecord::Base
  
  def self.import_rkb(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      rkb = find_by(brand: row["brand"].upcase, address_number: row["address_number"].to_i, 
      customer_id: row["customer_id"].to_i, date: row["date"], branch: row["branch"]) || MonthlyVisitPlan.new
      unless row["date"].nil?
        if rkb.id.nil?
          sales_name = Jde.get_sales_rkb(row["address_number"].to_i)
          customer = Jde.get_customer_rkb(row["customer_id"].to_i)
          row["sales_name"] = sales_name.nil? ? ' ' : sales_name.abalph.strip
          row["customer"] = customer.nil? ? ' ' : customer.abalph.strip
          row["date"] = row["date"].to_date
          row["customer_id"] = row["customer_id"].to_i
          row["address_number"] = row["address_number"].to_i
          row["brand"] = row["brand"].upcase!
          rkb.attributes = row.to_hash
        else
          rkb["date"] = row["date"]
        end
        rkb.save!
      end
    end
  end
  
end