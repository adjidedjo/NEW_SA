class ForecastsController < ApplicationController

  def management_forecast_by_sales
    start_date = params[:start_date].nil? ? Date.today - 30 : params[:start_date]
    end_date = params[:end_date].nil? ? Date.today : params[:end_date]
    @manag_brand = Forecast.calculation_forecasts_by_manage_sales(start_date, end_date)

    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "score_card", :filename => "score card #{params[:area]}.xlsx"}
    end
  end

  def management_forecast_by_bom
    start_date = params[:start_date].nil? ? Date.today - 30 : params[:start_date]
    end_date = params[:end_date].nil? ? Date.today : params[:end_date]
    @manag_bom = Forecast.calculation_forecasts_by_manage_bom(start_date, end_date)

    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "score_card", :filename => "score card #{params[:area]}.xlsx"}
    end
  end

  def management_forecast_by_branch
    start_date = params[:start_date].nil? ? Date.today - 30 : params[:start_date]
    end_date = params[:end_date].nil? ? Date.today : params[:end_date]
    channel = params[:channel].nil? ? 'RETAIL' : params[:channel]
    @manag_brand = Forecast.calculation_forecasts_by_manage_branch(start_date, end_date, channel)

    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "score_card", :filename => "score card #{params[:area]}.xlsx"}
    end
  end

  def management_forecast_by_brand
    start_date = params[:start_date].nil? ? Date.today - 30 : params[:start_date]
    end_date = params[:end_date].nil? ? Date.today : params[:end_date]
    channel = params[:channel].nil? ? 'RETAIL' : params[:channel]
    @manag_brand = Forecast.calculation_forecasts_by_brand(start_date, end_date, channel)

    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "score_card", :filename => "score card #{params[:area]}.xlsx"}
    end
  end

  def akurasi_forecast_sales
    if current_user.branch1 != nil || current_user.branch2 != nil
      @areas = Area.where("id IN ('#{current_user.branch1}','#{current_user.branch2}')")
    else
      @areas = Area.all
    end
    @brand = Brand.where(external: 0)
    @acv_forecast = Forecast.calculation_forecasts_by_branch_and_sales(params[:start_date], params[:end_date], params[:areas], params[:channel]) if params[:start_date].present?
  end

  def score_card
    gudang(current_user)
    area(current_user)
    @score_card = Forecast.score_card(params[:areas], params[:from_week], params[:to_week], params[:year]) if params[:from_week].present?
    @acv_forecast = Forecast.calculation_forecasts_by_branch_and_sales(params[:start_date], params[:end_date], params[:areas], params[:channel]) if params[:start_date].present?

    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "score_card", :filename => "score card #{params[:area]}.xlsx"}
    end
  end

  def score_card_salesman
    gudang(current_user)
    @score_card_salesman = Forecast.score_card_salesman(params[:areas], params[:week], params[:year])

    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "score_card_salesman", :filename => "score card salesman #{params[:areas]}.xlsx"}
    end
  end
  
  def customer_prog
    @cust_prog = Forecast.calculate_customer_prog(params[:areas])
    
    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "customer_prog", :filename => "customer progress #{params[:areas]}.xlsx"}
    end
  end
  
  def report_rkb
    @rkb = Forecast.calculate_rkb_report(params[:start_date], params[:end_date], params[:areas])
    
    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "rkb", :filename => "rkb #{params[:areas]}.xlsx"}
    end
  end
  
  def report_pbjm
    @pbjm = SalesOrder::PbjOrder.pbj_report(params[:start_date], params[:end_date], params[:brand])
    
    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "pbjm_elite", :filename => "pbjm #{params[:brand]} week #{params[:start_date].to_date.cweek}.xlsx"} if params[:brand] != 'ROYAL'
      format.xlsx {render :xlsx => "pbjm_royal", :filename => "pbjm #{params[:brand]} week #{params[:start_date].to_date.cweek}.xlsx"} if params[:brand] == 'ROYAL'
    end
  end
  
  def report_pbjm_cabang
    @pbjm_cabang = Jde.calculate_pbjm_cabang(params[:start_date], params[:end_date], params[:brand], params[:branch])
    
    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "pbjm_cabang", :filename => "pbjm #{params[:brand]} week #{params[:start_date].to_date.cweek}.xlsx"}
    end
    rescue ActiveRecord::ActiveRecordError => e
      redirect_to forecasts_pbjm_cabang_path, alert: 'Data tidak ditemukan, cek kembali inputan Branch Plan Anda!'
  end
  
  def dash_sales
    @sales_month = Penjualan::SalesmanSales.score_card_sales(current_user) if current_user.position == 'sales'
  end
  
  def rkm_sales_page
    @rkm_sales = Forecast.calculate_rkm_sales(Date.today.cweek, Date.today.year, current_user.address_number)
  end

  def nasional_aging_stock
    @aging_stock = Forecast.nasional_aging_stock(params[:brand]) if params[:brand].present? && params[:format] == 'xlsx'

    respond_to do |format|
      format.xlsx {render :xlsx => "aging_stock", :filename => "Aging Stock #{params[:brand]}.xlsx"}
    end
  end
  
  def rekap_report_rkm
    @pbj_recap_mingguan_admin = Forecast.calculate_rkm_recap_admin(params[:week], params[:year], params[:brand], params[:areas]) if params[:week].present? && params[:typ] == 'recap' && params[:format] == 'xlsx'
    @week = Date.commercial(params[:year].to_i, params[:week].to_i).to_date if params[:week].present?

    respond_to do |format|
      format.xlsx {render :xlsx => "rekap_rkm", :filename => "rkm recap #{params[:week]}.xlsx"}
    end
  end

  def pbjm_cabang
    if current_user.branch1 != nil || current_user.branch2 != nil
      @areas = Area.where("id IN ('#{current_user.branch1}','#{current_user.branch2}')")
    else
      @areas = Area.all
    end
    @brand = Brand.where(external: 0)
  end

  def report_rkm
    if current_user.branch1 != nil || current_user.branch2 != nil
      @areas = Area.where("id IN ('#{current_user.branch1}','#{current_user.branch2}')")
    else
      @areas = Area.all
    end
    @brand = Brand.where(external: 0)
    @pbj_mingguan = Forecast.calculate_rkm(params[:week], params[:year], params[:areas], params[:brand]) if params[:week].present? && params[:format].nil?
    @pbj_mingguan_admin = Forecast.calculate_rkm_admin(params[:week], params[:year], params[:brand]) if params[:week].present? && params[:typ] == 'detail' && params[:format] == 'xlsx'
    @pbj_recap_mingguan_admin = Forecast.calculate_rkm_recap_admin(params[:week], params[:year], params[:brand]) if params[:week].present? && params[:typ] == 'recap' && params[:format] == 'xlsx'
    @week = Date.commercial(params[:year].to_i, params[:week].to_i).to_date if params[:week].present?

    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "rkm", :filename => "rkm #{params[:areas]}.xlsx"}
    end
  end

  def report_forecasts_years
    if current_user.branch1 != nil || current_user.branch2 != nil
      @areas = Area.where("id IN ('#{current_user.branch1}','#{current_user.branch2}')")
    else
      @areas = Area.all
    end
    @brand = Brand.where(external: 0)
    @acv_forecast = Forecast.calculation_forecast_year(params[:start_date], params[:end_date], params[:areas], params[:brand]) if params[:start_date].present?
  end

  def report_forecasts_salesman
    if current_user.branch1 != nil || current_user.branch2 != nil
      @areas = Area.where("id IN ('#{current_user.branch1}','#{current_user.branch2}')")
    else
      @areas = Area.all
    end
    @brand = Brand.where(external: 0)
    @acv_forecast = Forecast.calculation_forecasts_salesman(params[:start_date], params[:end_date], params[:areas], params[:brand]) if params[:start_date].present?
  end

  def report_forecasts_items
    gudang(current_user)
    @brand = Brand.where(external: 0)
    @acv_forecast = Forecast.calculation_forecasts(params[:start_date], params[:end_date], params[:areas]) if params[:start_date].present?
  end

  def report_forecasts_branches
    if current_user.branch1 != nil || current_user.branch2 != nil
      @areas = Area.where("id IN ('#{current_user.branch1}','#{current_user.branch2}')")
    else
      @areas = Area.all
    end
    @brand = Brand.where(external: 0)
    @acv_forecast = Forecast.calculation_forecasts_by_branch(params[:start_date], params[:end_date], params[:areas]) if params[:start_date].present?
  end

  def report_forecasts_directs
    if current_user.branch1 != nil || current_user.branch2 != nil
      @areas = Area.where("id IN ('#{current_user.branch1}','#{current_user.branch2}')")
    else
      @areas = Area.all
    end
    @brand = Brand.where(external: 0)
    @acv_forecast_dir = Forecast.calculation_direct_forecast(params[:start_date], params[:end_date], params[:areas]) if params[:start_date].present?
  end

  private

  def area(user)
    if user.branch1 != nil || user.branch2 != nil
      @areas = Area.where("id IN ('#{user.branch1}','#{user.branch2}')")
    else
      @areas = Area.all
    end
    return @areas
  end

  def gudang(user)
    if user.branch1 != nil || user.branch2 != nil
      @gudang = Gudang.where("area_id IN ('#{user.branch1}','#{user.branch2}')")
    else
      @gudang = Gudang.all
    end
    return @gudang
  end

  def index
  end
end
