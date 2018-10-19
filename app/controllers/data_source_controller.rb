class DataSourceController < ApplicationController
  
  def item_ledger
    @areas = Area.all
    @brand = Brand.where(external: 0)
    @ledger = Stock::ItemAvailability.ledger(params[:start_date], params[:end_date]) if params[:start_date].present? && params[:end_date].present?    
      
    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "item_ledger", :filename => "summary item ledger.xlsx"}
    end
  end
  
  def sales_report
    @areas = Area.all
    @brand = Brand.where(external: 0)
    @sales = Penjualan::Sale.export_sales_report(params[:start_date], params[:end_date]) if params[:start_date].present? && params[:end_date].present?    
      
    respond_to do |format|
      format.html
      format.xlsx {render :xlsx => "sales_report", :filename => "sales report from '#{params[:start_date]}' to '#{params[:end_date]}'.xlsx"}
    end
  end
end