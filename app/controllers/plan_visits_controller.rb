class PlanVisitsController < ApplicationController
  before_action :set_plan_visit, only: [:show, :edit, :update, :destroy]

  # GET /plan_visits
  # GET /plan_visits.json
  def index
    @plan_visits = PlanVisit.index_all(params[:date], current_user)
  end

  # GET /plan_visits/1
  # GET /plan_visits/1.json
  def show
  end

  # GET /plan_visits/new
  def new
    @plan_visit = PlanVisit.new
    @plan_visit.customer_plan_visits.build
    @customer = Customer.where("i_class = 'RET'").group(:name)
    @salesman = current_user.branch1.present? ?
      PlanVisit.find_by_sql("SELECT nama, id FROM salesmen
      WHERE branch_id = '#{current_user.branch1}' ORDER BY nama ASC") : 
      PlanVisit.find_by_sql("SELECT nama, id FROM salesmen ORDER BY nama ASC")
    @brand = PlanVisit.find_by_sql("SELECT jde_brand, id FROM tbbjmerk")
  end

  # GET /plan_visits/1/edit
  def edit
    @salesman = Salesman.find(@sales_productivity.salesmen_id)
    @customer = Customer.where("i_class = 'RET'").group(:name)
  end

  # POST /plan_visits
  # POST /plan_visits.json
  def create
    @plan_visit = PlanVisit.new(plan_visit_params)

    respond_to do |format|
      if @plan_visit.save
        format.html { redirect_to plan_visits_path, notice: "Sales productivity sukses dibuat" }
        format.json { render :show, status: :created, location: @plan_visit }
      else
        format.html { redirect_to new_plan_visit_path, flash: {alert: "Pembuatan Gagal. Isi Customer atau cek kembali inputan anda"} }
      end
    end
  end

  # PATCH/PUT /plan_visits/1
  # PATCH/PUT /plan_visits/1.json
  def update
    respond_to do |format|
      if @plan_visit.update(plan_visit_params)
        format.html { redirect_to @plan_visit, notice: 'Plan visit was successfully updated.' }
        format.json { render :show, status: :ok, location: @plan_visit }
      else
        format.html { render :edit }
        format.json { render json: @plan_visit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plan_visits/1
  # DELETE /plan_visits/1.json
  def destroy
    @plan_visit.destroy
    respond_to do |format|
      format.html { redirect_to plan_visits_url, notice: 'Plan visit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan_visit
      @plan_visit = PlanVisit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plan_visit_params
      params.require(:plan_visit).permit(:sales_id, :brand, :city, :date_visit, 
      :hotel, :accomodation, :allowance, :branch_id,
      customer_plan_visits_attributes: [:call_visit, :customer, :_destroy])
    end
end
