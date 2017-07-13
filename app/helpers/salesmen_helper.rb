module SalesmenHelper
  def find_area(area)
    Area.find(area).area
  end
end
