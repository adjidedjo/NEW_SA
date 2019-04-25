class SalesTarget < ApplicationRecord
  self.table_name = "sales_target_values"
  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      target = find_by(brand: row["brand"], address_number: row["address_number"].to_i, branch: row["branch"],
      month: row["month"], year: row["year"]) || new
      unless row["amount"].nil? || row["amount"] == 0
        if target.id.nil?
          sales_name = Jde.get_sales_rkb(row["address_number"].to_i)
          row["name"] = sales_name.nil? ? ' ' : sales_name.abalph.strip
        target.attributes = row.to_hash
        else
          target["amount"] = row["amount"]
        end
      target.save!
      end
    end
  end
end