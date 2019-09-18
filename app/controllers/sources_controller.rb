class SourcesController < ApplicationController

  def upload_forecast
  end

  def import_target_sales
    SalesTarget.import(params[:file])
    redirect_to sources_upload_forecast_url, notice: 'Salesmen Targets imported.'
  end

  def import
    Forecast.import(params[:file])
    redirect_to sources_upload_forecast_url, notice: 'Forecasts imported.'
  end

  def import_weekly
    ForecastWeekly.import_weekly(params[:file])
    redirect_to sources_upload_forecast_url, notice: "RKM with file name '#{params[:file].original_filename}' imported."
  end

  def import_rkb
    MonthlyVisitPlan.import_rkb(params[:file])
    redirect_to sources_upload_forecast_url, notice: "RKB with file name '#{params[:file].original_filename}' imported."
  end
  
  def item_ledger
    if current_user.branch1 != nil || current_user.branch2 != nil
      @areas = Area.where("id IN ('#{current_user.branch1}','#{current_user.branch2}')")
    else
      @areas = Area.all
    end
    @brand = Brand.where(external: 0)
    @ledger = Stock::ItemAvailability.ledger(params[:start_date], params[:end_date]) if params[:start_date].present? && params[:end_date].present?

    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "item_ledger", :filename => "summary item ledger.xlsx"}
    end
  end

  def sales_report
    if current_user.branch1 != nil || current_user.branch2 != nil
      @areas = Area.where("id IN ('#{current_user.branch1}','#{current_user.branch2}')")
    else
      @areas = Area.all
    end
    @brand = Brand.where(external: 0)
    @sales = Penjualan::Sale.export_sales_report(params[:start_date], params[:end_date], params[:areas]) if params[:start_date].present? && params[:end_date].present?

    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "sales_report", :filename => "sales report from #{params[:start_date]}-#{params[:end_date]}.xlsx"}
    end
  end

  def sold_as_order
    @areas = Branch.where("jde_branch is not null")
    @brand = Brand.where(external: 0)
    @proov = SalesOrder::Order.generate_proving_reports(params[:areas], params[:start_date], params[:end_date]) if params[:start_date].present? && params[:end_date].present?

    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "prooving_report", :filename => "proving report #{params[:areas]} #{params[:start_date]}-#{params[:end_date]}.xlsx"}
    end
  end
end