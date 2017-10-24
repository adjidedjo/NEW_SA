class ForecastsController < ApplicationController
  
  def index
  end

  def upload_forecast
  end

  def import
    Forecast.import(params[:file])
    redirect_to forecasts_upload_forecast_url, notice: 'Forecasts imported.'
  end
end
