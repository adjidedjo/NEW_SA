class PagesController < ApplicationController
  layout 'pages'

  def login
  end

  def register
  end

  def recover
  end

  def lock
  end

  # set another layout for a specific action
  def template
    if current_user.position = 'sales'
      redirect_to forecasts_dash_sales_path
    else
      render :layout => 'application'
    end
  end

  def notfound
  end

  def error500
  end

  def maintenance
  end
end
