module PenjualanConcern
  extend ActiveSupport::Concern

  ########## MONTHLY
  def last_month_city_summary
    @city_month_sum = Penjualan::Sale.monthly_city_summary(initialize_brach_id, initialize_brand)
  end
  
  def this_month_product_summary
    @product_month_summary = Penjualan::Sale.monthly_product_summary(initialize_brach_id, initialize_brand)
  end

  def last_month_summary_brand
    @brand_month_ago = Penjualan::Sale.a_month_ago(initialize_brach_id, initialize_brand)
    gon.last_month_date = 1.month.ago.strftime("%B %y")
    gon.last_month_ago = @brand_month_ago.empty? ? 0 : @brand_month_ago[0]['jumlah']
  end

  def two_month_ago_summary_brand
    @brand_2_month_ago = Penjualan::Sale.two_month_ago(initialize_brach_id, initialize_brand)
    gon.two_month_ago_date = 2.month.ago.strftime("%B %y")
    gon.two_month_ago = @brand_2_month_ago.empty? ? 0 : @brand_2_month_ago[0]['jumlah']
  end

  def three_month_ago_summary_brand
    @brand_3_month_ago = Penjualan::Sale.three_month_ago(initialize_brach_id, initialize_brand)
    gon.three_month_ago_date = 3.month.ago.strftime("%B %y")
    gon.three_month_ago = @brand_3_month_ago.empty? ? 0 : @brand_3_month_ago[0]['jumlah']
  end

  def four_month_ago_summary_brand
    @brand_4_month_ago = Penjualan::Sale.four_month_ago(initialize_brach_id, initialize_brand)
    gon.four_month_ago_date = 4.month.ago.strftime("%B %y")
    gon.four_month_ago = @brand_4_month_ago.empty? ? 0 : @brand_4_month_ago[0]['jumlah']
  end
  
  def all_months_reports
    @all_month_brand = @brand_month_ago
    @all_month_brand << @brand_2_month_ago.first
    @all_month_brand << @brand_3_month_ago.first
    @all_month_brand << @brand_4_month_ago.first
  end
  ########## END MONTHLY

  ########## WEEKLY
  def this_week_city_summary
    @city_week_sum = Penjualan::Sale.weekly_city_summary(initialize_brach_id, initialize_brand)
  end
  
  def this_week_product_summary
    @product_summary = Penjualan::Sale.weekly_product_summary(initialize_brach_id, initialize_brand)
  end

  def last_week_summary_brand
    @brand_week_ago = Penjualan::Sale.a_week_ago(initialize_brach_id, initialize_brand)
    gon.last_week_date = 1.week.ago.beginning_of_week.to_date.strftime("%d/%m/%y") + " - " + 1.week.ago.end_of_week.to_date.strftime("%d/%m/%y")
    gon.last_week_ago = @brand_week_ago.empty? ? 0 : @brand_week_ago[0]['jumlah']
  end

  def two_weeks_ago_summary_brand
    @brand_2_week_ago = Penjualan::Sale.two_weeks_ago(initialize_brach_id, initialize_brand)
    gon.two_week_ago_date = 2.week.ago.beginning_of_week.to_date.strftime("%d/%m/%y") + " - " + 2.week.ago.end_of_week.to_date.strftime("%d/%m/%y")
    gon.two_week_ago = @brand_2_week_ago.empty? ? 0 : @brand_2_week_ago[0]['jumlah']
  end

  def three_weeks_ago_summary_brand
    @brand_3_week_ago = Penjualan::Sale.three_weeks_ago(initialize_brach_id, initialize_brand)
    gon.three_week_ago_date = 3.week.ago.beginning_of_week.to_date.strftime("%d/%m/%y") + " - " + 3.week.ago.end_of_week.to_date.strftime("%d/%m/%y")
    gon.three_week_ago = @brand_3_week_ago.empty? ? 0 : @brand_3_week_ago[0]['jumlah']
  end

  def four_weeks_ago_summary_brand
    @brand_4_week_ago = Penjualan::Sale.four_weeks_ago(initialize_brach_id, initialize_brand)
    gon.four_week_ago_date = 4.week.ago.beginning_of_week.to_date.strftime("%d/%m/%y") + " - " + 4.week.ago.end_of_week.to_date.strftime("%d/%m/%y")
    gon.four_week_ago = @brand_3_week_ago.empty? ? 0 : @brand_3_week_ago[0]['jumlah']
  end
  
  def all_weeks_reports
    @all_week_brand = @brand_week_ago
    @all_week_brand << @brand_2_week_ago.first
    @all_week_brand << @brand_3_week_ago.first
    @all_week_brand << @brand_4_week_ago.first
  end
  ########## END WEEKLY

  ########## CHANNEL
  def monthly_channel
    @retail_monthly = Penjualan::Sale.monthly_channel(initialize_brach_id, initialize_brand).select {|c| c["tipecust"] == "RETAIL"}
    @showroom_monthly = Penjualan::Sale.monthly_channel(initialize_brach_id, initialize_brand).select {|c| c["tipecust"] == "SHOWROOM"}
    @direct_monthly = Penjualan::Sale.monthly_channel(initialize_brach_id, initialize_brand).select {|c| c["tipecust"] == "DIRECT"}
    @modern_monthly = Penjualan::Sale.monthly_channel(initialize_brach_id, initialize_brand).select {|c| c["tipecust"] == "MODERN"}
    @project_monthly = Penjualan::Sale.monthly_channel(initialize_brach_id, initialize_brand).select {|c| c["tipecust"] == "PROJECT"}
    @uncategorized_monthly = Penjualan::Sale.monthly_channel(initialize_brach_id, initialize_brand).select {|c| c["tipecust"] == "-"}
  end

  def weekly_channel
    @retail = Penjualan::Sale.weekly_channel(initialize_brach_id, initialize_brand).select {|c| c["tipecust"] == "RETAIL"}
    @showroom = Penjualan::Sale.weekly_channel(initialize_brach_id, initialize_brand).select {|c| c["tipecust"] == "SHOWROOM"}
    @direct = Penjualan::Sale.weekly_channel(initialize_brach_id, initialize_brand).select {|c| c["tipecust"] == "DIRECT"}
    @modern = Penjualan::Sale.weekly_channel(initialize_brach_id, initialize_brand).select {|c| c["tipecust"] == "MODERN"}
    @project = Penjualan::Sale.weekly_channel(initialize_brach_id, initialize_brand).select {|c| c["tipecust"] == "PROJECT"}
    @uncategorized = Penjualan::Sale.weekly_channel(initialize_brach_id, initialize_brand).select {|c| c["tipecust"] == "-"}
  end
  ########## END CHANNEL
end