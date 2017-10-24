class Forecast < ActiveRecord::Base
  
  def self.import(file)
  spreadsheet = Roo::Spreadsheet.open(file.path)
  header = spreadsheet.row(1)
  (2..spreadsheet.last_row).each do |i|
    row = Hash[[header, spreadsheet.row(i)].transpose]
    forecast = find_by(item_number: row["item_number"], branch: row["branch"], month: row["month"], year: row["year"]) || new
    if forecast["id"].nil?
      forecast.attributes = row.to_hash
    else
      forecast["quantity"] = row["quantity"]
    end
    forecast.save!
  end
end  

end