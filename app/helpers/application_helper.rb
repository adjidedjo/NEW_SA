module ApplicationHelper
  include RolesHelper
  
  def find_area(area)
    Area.find(area).area
  end
  
  def find_branch(branch)
    Branch.get_cabang(branch)
  end
  
  def calculate_by_day(forecast, end_date)
    (forecast/get_days_in_month(end_date))*end_date.to_date.day.to_i
  end
  
  def get_days_in_month(end_date)
    Time.days_in_month(end_date.to_date.month, end_date.to_date.year)
  end
  
  def branch_forcast(forecast,actual)
    val = (((actual.to_f/forecast.to_f)*100) > 100) ? 0 : ((100 - (actual.to_f/forecast.to_f)*100)).abs
    return number_to_percentage(val, precision: 0)
  end
  
  def eforecast(forecast,actual)
    absolute = (actual - forecast).abs
    val = (absolute.to_f/forecast.to_f)*100
    return number_to_percentage(val, precision: 0)
  end
  
  def aforecast(forecast,actual,start,end_date)
    forcast = forecast.nil? ? 0 : calculate_by_day(forecast, end_date)
    absolute = (actual - forcast).abs
    val = (((actual.to_f/forcast.to_f)*100) > 100) ? 0 : ((100 - (actual.to_f/forcast.to_f)*100)).abs
    return number_to_percentage(val, precision: 0)
  end
  
  def link_to_add_row(name, f, association, **args)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize, f: builder)
    end
    link_to(name, '#', class: "add_fields " + args[:class], data: {id: id, fields: fields.gsub("\n", "")})
  end
  
  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-error", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in") do 
        concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
        concat message 
      end)
    end
    nil
end
  
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
    Salesman.find(sales)
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
