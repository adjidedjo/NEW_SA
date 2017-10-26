class ForecastsController < ApplicationController
  
  def report_forecasts_branches
    @areas = Area.all
    @acv_forecast = Forecast.calculation_forecasts(params[:date][:month], params[:date][:year], params[:areas]) if params[:date].present?
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
