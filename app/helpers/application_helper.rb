module ApplicationHelper
  include RolesHelper
  
  def checking_status(status)
    if status == 'D'
      'Display'
    elsif status == 'N'
      'Normal'
    elsif status == 'C'
      'Clearance'
    elsif status == 'S'
      'Service'
    elsif status == 'TOTAL'
      'TOTAL'
    end
  end
  
  def monthly_range
    Date.yesterday.last_month.beginning_of_month.to_date..Date.yesterday.last_month.end_of_month.to_date
  end
  
  def find_sales(sales)
    User.find(sales)
  end
  
  def find_brand(brand)
    SalesProductivity.find_by_sql("SELECT jde_brand FROM tbbjmerk WHERE id = '#{brand}'").first
  end
  
  def currency(price)
    number_to_currency(price, :precision => 0, :unit => "", :delimiter => ",")
  end
  
  def precision(avg)
    number_with_precision(avg, precision: 2)
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
  
  def coloring_target(val)
    if val.nil?
      ''
    elsif val >= 0 && val < 60
      'neg'
    elsif val >= 60 && val < 80
      'yel'
    elsif val >= 80
      'pos'
    end
  end
  
  def triangle(val)
    if val.nil?
      ''
    else
      val >= 0 ? 'triangle-up' : 'neg'
    end
  end
  
  def coloring(val)
    if val.nil?
      ''
    else
      val >= 0 ? 'arrowUp' : 'arrowDown'
    end
  end
  
  def cpercent(val)
    number_to_percentage(val, precision: 0)
  end
end
