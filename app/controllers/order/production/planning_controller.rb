class Order::Production::PlanningController < ApplicationController
  
  def upload_for_bom
    if params[:file].present?
      @bom = BillOfMaterial.import(params[:file])
    end
  end
  
  def import
    BillOfMaterial.import(params[:file])
    redirect_to planning_upload_for_bom_url, notice: 'BOM Has Been Calculated.'
  end
  
  def outstanding_order
    @out_daily = OutstandingProduction.get_outstanding
  end
  
  def aging_orders
    @bp_prod = BranchProduction.all
    @age_daily = SalesOrder::OutstandingProduction.aging_order_calculation(params[:branch]) if params[:branch].present?
    render template: "order/template_order/aging_orders"
  end
end