class ForecastsController < ApplicationController
  def rekap_report_rkm
    @pbj_recap_mingguan_admin = Forecast.calculate_rkm_recap_admin(params[:week], params[:year], params[:brand]) if params[:week].present? && params[:typ] == 'recap' && params[:format] == 'xlsx'
    @week = Date.commercial(params[:year].to_i, params[:week].to_i).to_date if params[:week].present?

    respond_to do |format|
      format.xlsx {render :xlsx => "rekap_rkm", :filename => "rkm recap #{params[:week]}.xlsx"}
    end
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
    if current_user.branch1 != nil || current_user.branch2 != nil
      @areas = Area.where("id IN ('#{current_user.branch1}','#{current_user.branch2}')")
    else
      @areas = Area.all
    end
    @brand = Brand.where(external: 0)
    @acv_forecast = Forecast.calculation_forecasts(params[:start_date], params[:end_date], params[:areas], params[:brand]) if params[:start_date].present?
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

  def index
  end

  def upload_forecast
  end

  def import
    Forecast.import(params[:file])
    redirect_to forecasts_upload_forecast_url, notice: 'Forecasts imported.'
  end

  def import_weekly
    ForecastWeekly.import_weekly(params[:file])
    redirect_to forecasts_upload_forecast_url, notice: 'Forecasts Weekly imported.'
  end
end
