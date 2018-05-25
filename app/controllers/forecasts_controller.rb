class ForecastsController < ApplicationController
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
end
