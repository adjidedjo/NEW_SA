module PenjualanConcern
  include ApplicationHelper
  extend ActiveSupport::Concern

  ########## MONTHLY
  
  def retail_nasional_this_month_branches_conc
    @products_monthnas_summary = Penjualan::Sale.retail_nasional_this_month_products(@date, initialize_brand)
    @branches_monthnas_summary = Penjualan::Sale.retail_nasional_this_month_branches(@date, initialize_brand)
    @monthnas_summary = Penjualan::Sale.retail_nasional_this_month_total(@date, initialize_brand)
  end
  
  def retail_nasional_this_month_conc
    summaries = Penjualan::Sale::retail_nasional_this_month(@date, initialize_brand)
    # target_sum = Penjualan::Sale::target_retail_nasional_monthly(initialize_brand)
    gon.summaries = summaries.map { |u| [Date::ABBR_MONTHNAMES[u.fiscal_month], (u.harga/10000000)] }.to_a
    # gon.target = target_sum.map { |u| [Date::ABBR_MONTHNAMES[u.month], (u.jumlah)] }.to_a
  end
  
  def retail_nasional_this_month_branch_conc
    summaries = Penjualan::Sale::retail_nasional_this_month_branch(@date, initialize_brand)
    gon.summaries_branch = summaries.map { |u| [u.branch.gsub(/Cabang/,''), (u.harga/10000000)] }.to_a
  end
  
  def retail_productivity_conc
    @sales_prod = SalesProductivity.retail_productivity(initialize_brach_id, initialize_brand)
    gon.productivity = @sales_prod.map { |u| [u.tanggalsj.strftime('%d/%m'), u.prod] }.to_a
  end
  
  def retail_success_rate_conc
    @sales = SalesProductivityReport.report(initialize_brach_id, initialize_brand)
  end
  
  def retail_nasional_monthly_branches_conc
    @branches_monthnas_summary = Penjualan::Sale.retail_nasional_monthly_branches(initialize_brand)
    @monthnasi_summary = Penjualan::Sale.retail_nasional_monthly_total(initialize_brand)
  end
  
  def retail_nasional_monthly_conc
    summaries = Penjualan::Sale::retail_nasional_monthly(initialize_brand)
    # target_sum = Penjualan::Sale::target_retail_nasional_monthly(initialize_brand)
    gon.summaries = summaries.map { |u| [Date::ABBR_MONTHNAMES[u.fiscal_month], (u.harga/10000000)] }.to_a
    # gon.target = target_sum.map { |u| [Date::ABBR_MONTHNAMES[u.month], (u.jumlah)] }.to_a
  end
  
  def retail_nasional_monthly_branch_conc
    summaries = Penjualan::Sale::retail_nasional_monthly_branch(initialize_brand)
    gon.summaries_branch = summaries.map { |u| [u.branch.gsub(/Cabang/,''), (u.harga/10000000)] }.to_a
  end
  
  def sales_through
    Penjualan::Sale.sales_through(initialize_brach_id, initialize_brand)
  end
  
  def otd
    @otd = Penjualan::Sale.on_time_delivery(@date, initialize_brach_id, initialize_brand)
    @brand_name = initialize_brand
    gon.ontime = @otd.first.ontime.to_i
    gon.late = @otd.first.late.to_i
    gon.superlate = @otd.first.superlate.to_i
  end
  
  def monthly_salesman_summary
    @last_month_salesman = Penjualan::Sale.monthly_salesman_summary(@date, initialize_brach_id, initialize_brand)
  end
  
  def monthly_article_summary
    @last_month_article = Penjualan::Sale.monthly_article_summary(@date, initialize_brach_id, initialize_brand)
  end
  
  def monthly_customer_summary
    @last_month_customer = Penjualan::Sale.monthly_customer_summary(@date, initialize_brach_id, initialize_brand)
  end
  
  def revenue_last_month
    @sales_revenue_last_month = Penjualan::SaleDaily.revenue_last_month(@date, initialize_brach_id, initialize_brand)
  end
  
  def monthly_summaries
    summaries = Penjualan::Sale.monthly_summaries(initialize_brach_id, initialize_brand)
    target_sum = Penjualan::Sale.target_monthly_summaries(initialize_brach_id, initialize_brand)
    gon.summaries = summaries.map { |u| [Date::ABBR_MONTHNAMES[u.fiscal_month], (u.jumlah)] }.to_a
    gon.target = target_sum.map { |u| [Date::ABBR_MONTHNAMES[u.month], (u.jumlah)] }.to_a
  end
  
  def last_month_city_summary
    @city_month_sum = Penjualan::Sale.monthly_city_summary(@date, initialize_brach_id, initialize_brand)
  end
  
  def this_month_product_summary
    @product_month_summary = Penjualan::Sale.monthly_product_summary(@date, initialize_brach_id, initialize_brand)
  end
  ########## END MONTHLY

  ########## WEEKLY
  
  def sales_stock_rate_conc
    sumssr = Penjualan::SalesStockRate.sales_stock_rate_weekly_summary(initialize_brach_id, initialize_brand)
    gon.sumssr = sumssr.map { |u| [u.weekly_name, u.ssr] }.to_a
  end
  
  def sales_stock_rate_product_conc
    @ssr_product = Penjualan::SalesStockRate.sales_stock_rate_weekly_product(initialize_brach_id, initialize_brand)
  end
  
  def retail_nasional_weekly_branch_conc
    @ret_nas_weekbranch =  Penjualan::Sale::retail_nasional_weekly_branch(initialize_brand)
  end
  
  def retail_nasional_weekly_conc
    summaries =  Penjualan::Sale::retail_nasional_weekly(initialize_brand)
    gon.summaries = summaries.map { |u| [u.weekly_name, (u.val/1000000)] }.to_a
  end
  
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