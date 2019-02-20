class ForecastsController < ApplicationController
  def report_rkm
    @areas = Area.all
    @brand = Brand.where(external: 0)
    @pbj_mingguan = Forecast.calculate_rkm(params[:week], params[:year], params[:areas], params[:brand]) if params[:week].present? && params[:format].nil?
    @pbj_mingguan_admin = Forecast.calculate_rkm_admin(params[:week], params[:year], params[:areas]) if params[:week].present? && params[:format] == 'xlsx'
    @week = Date.commercial(params[:year].to_i, params[:week].to_i).to_date if params[:week].present?
    
    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "rkm", :filename => "rkm #{params[:areas]}.xlsx"}
    end
  end
  
  def report_forecasts_years
    @areas = Area.all
    @brand = Brand.where(external: 0)
    @acv_forecast = Forecast.calculation_forecast_year(params[:start_date], params[:end_date], params[:areas], params[:brand]) if params[:start_date].present?
  end
  
  def report_forecasts_salesman
    @areas = Area.all
    @brand = Brand.where(external: 0)
    @acv_forecast = Forecast.calculation_forecasts_salesman(params[:start_date], params[:end_date], params[:areas], params[:brand]) if params[:start_date].present?
  end
  
  def report_forecasts_items
    @areas = Area.all
    @brand = Brand.where(external: 0)
    @acv_forecast = Forecast.calculation_forecasts(params[:start_date], params[:end_date], params[:areas], params[:brand]) if params[:start_date].present?
  end

  def report_forecasts_branches
    @areas = Area.all
    @brand = Brand.where(external: 0)
    @acv_forecast = Forecast.calculation_forecasts_by_branch(params[:start_date], params[:end_date], params[:areas]) if params[:start_date].present?
  end

  def report_forecasts_directs
    @areas = Area.all
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
