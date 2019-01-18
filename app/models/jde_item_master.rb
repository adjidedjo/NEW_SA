class JdeItemMaster < ActiveRecord::Base
  establish_connection :jdeoracle
  self.table_name = "PRODDTA.F4101" #im

  def self.get_desc_forecast(item_number)
    item = find_by_sql("SELECT * FROM PRODDTA.F4101 WHERE IMLITM LIKE '#{item_number}%'").first
  end

  def self.date_to_julian(date)
    date = date.to_date
    1000*(date.year-1900)+date.yday
  end

  def self.brand(brand)
    if brand == "ELITE"
      2
    elsif brand == "LADY"
      4
    elsif brand == "PURECARE"
      8
    elsif brand == "TECHGEL"
      7
    end
  end
end
