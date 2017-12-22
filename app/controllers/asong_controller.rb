class AsongController < ApplicationController
  def report_by_branch
    @areas = Area.all
    @brand = Brand.where(external: 0)
    @acv_asong = AsongOrder.calculation_asong_by_branch(params[:start_date], params[:end_date], params[:areas]) if params[:start_date].present?
  end
end