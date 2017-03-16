module PenjualanDailyConcern
  extend ActiveSupport::Concern
  
  included do
    before_action do
      initialize_daily
    end
  end
  
  def daily_summary
    @daily_sum = Penjualan::SaleDaily.daily_summary(initialize_brach_id, initialize_brand)
    gon.day_5 = @five_day_ago.strftime("%Y/%m/%d")
    gon.day_4 = @four_day_ago.strftime("%Y/%m/%d")
    gon.day_3 = @three_day_ago.strftime("%Y/%m/%d")
    gon.day_2 = @two_day_ago.strftime("%Y/%m/%d")
    gon.day_1 = @last_day.strftime("%Y/%m/%d")
    qty_6 = @daily_sum.select {|c| c["tanggalsj"] == @six_day_ago}
    gon.qty_6 = qty_6.first.nil? ? 0 : qty_6.first.jumlah
    qty_5 = @daily_sum.select {|c| c["tanggalsj"] == @five_day_ago}
    gon.qty_5 = qty_5.first.nil? ? 0 : qty_5.first.jumlah
    qty_4 = @daily_sum.select {|c| c["tanggalsj"] == @four_day_ago}
    gon.qty_4 = qty_4.first.nil? ? 0 : qty_4.first.jumlah
    qty_3 = @daily_sum.select {|c| c["tanggalsj"] == @three_day_ago}
    gon.qty_3 = qty_3.first.nil? ? 0 : qty_3.first.jumlah
    qty_2 = @daily_sum.select {|c| c["tanggalsj"] == @two_day_ago}
    gon.qty_2 = qty_2.empty? ? 0 : qty_2.first.jumlah
    qty_1 = @daily_sum.select {|c| c["tanggalsj"] == @last_day}
    gon.qty_1 = qty_1.first.nil? ? 0 : qty_1.first.jumlah
  end
  
  def daily_summary_data
    @daily_sum = Penjualan::SaleDaily.daily_summary(initialize_brach_id, initialize_brand)
  end
  
  def product_daily
    @daily_prod = Penjualan::SaleDaily.daily_product(initialize_brach_id, initialize_brand)
  end
  
  def salesman_daily
    @daily_salesman = Penjualan::SaleDaily.daily_salesman(initialize_brach_id, initialize_brand)
  end
  
  def customer_daily
    @daily_customer = Penjualan::SaleDaily.daily_customer(initialize_brach_id, initialize_brand)
  end
  
  def initialize_daily
    @last_day = 1.day.ago.to_date
    @two_day_ago = 2.day.ago.to_date
    @three_day_ago = 3.day.ago.to_date
    @four_day_ago = 4.day.ago.to_date
    @five_day_ago = 5.day.ago.to_date
    @six_day_ago = 6.day.ago.to_date
  end
end