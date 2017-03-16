module ApplicationHelper
  include RolesHelper
  def currency(price)
    number_to_currency(price, :precision => 0, :unit => "", :delimiter => ".")
  end
  
  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end
  
  def date_to_julian(date)
    1000*(date.year-1900)+date.yday
  end

  def julian_to_date(jd_date)
    Date.parse((jd_date+1900000).to_s, 'YYYYYDDD')
  end
end
