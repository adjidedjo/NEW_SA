class SalesProductivitiesController < ApplicationController
  # GET /sales_productivities
  # GET /sales_productivities.json

  def import
    SalesProductivity.import(params[:file])
    redirect_to upload_rkb_sales_productivities_url, notice: 'RKB imported.'
  end
  
  def upload_rkb
    
  end
  
  def index
    month = params[:date].nil? ? Date.today.month : params[:date][:month]
    year = params[:date].nil? ? Date.today.year : params[:date][:year]
    @sales_productivities = current_user.branch1.present? ? SalesProductivity.where("MONTH(date) = ? AND YEAR(date) = ? AND branch_id = ?",
    month, year, current_user.branch1) : SalesProductivity.where("MONTH(date) = ? AND YEAR(date) = ?",
    month, year)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sales_productivities }
    end
  end

  # GET /sales_productivities/1
  # GET /sales_productivities/1.json
  def show
    @sales_productivity = SalesProductivity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sales_productivity }
    end
  end

  # GET /sales_productivities/new
  # GET /sales_productivities/new.json
  def new
    @customer = Customer.where("i_class = 'RET'").group(:name)
    @sales_productivity = SalesProductivity.new
    @sales_productivity.sales_productivity_customers.build
    @salesman = current_user.branch1.present? ?
    SalesProductivity.find_by_sql("SELECT nama, id FROM salesmen
    WHERE branch_id = '#{current_user.branch1}' ORDER BY nama ASC") : SalesProductivity.find_by_sql("SELECT nama, id FROM salesmen ORDER BY nama ASC")
    @brand = SalesProductivity.find_by_sql("SELECT jde_brand, id FROM tbbjmerk")
  end

  # GET /sales_productivities/1/edit
  def edit
    @sales_productivity = SalesProductivity.find(params[:id])
    @salesman = Salesman.find(@sales_productivity.salesmen_id)
  end

  # POST /sales_productivities
  # POST /sales_productivities.json
  def create
    @sales_productivity = SalesProductivity.new(sales_productivity_params)
    @sales_productivity.date = sales_productivity_params[:date].to_date
    @sales_productivity.branch_id = Salesman.find(sales_productivity_params[:salesmen_id]).branch_id
    @sales_productivity.month = sales_productivity_params[:date].to_date.month
    @sales_productivity.year = sales_productivity_params[:date].to_date.year

    respond_to do |format|
      if @sales_productivity.save
        format.html { redirect_to new_sales_productivity_path, notice: "Sales productivity sukses dibuat" }
        format.json { render json: @sales_productivity, status: :created, location: @sales_productivity }
      else
        format.html { redirect_to new_sales_productivity_path, flash: {alert: "Pembuatan Gagal. Isi Customer atau cek kembali inputan anda"} }
      end
    end
  end

  # PUT /sales_productivities/1
  # PUT /sales_productivities/1.json
  def update
    @sales_productivity = SalesProductivity.find(params[:id])

    respond_to do |format|
      if @sales_productivity.update(sales_productivity_params)
        format.html { redirect_to sales_productivities_path, notice: 'Sales productivity was successfully updated.' }
        format.json { head :ok }
      else
        render action: :new
      end
    end
  end

  # DELETE /sales_productivities/1
  # DELETE /sales_productivities/1.json
  def destroy
    @sales_productivity = SalesProductivity.find(params[:id])
    @sales_productivity.destroy

    respond_to do |format|
      format.html { redirect_to sales_productivities_url }
      format.json { head :ok }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_acquittance
    @productivity = SalesProductivity.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def sales_productivity_params
    params.require(:sales_productivity).permit(:id, :date, :salesmen_id, :branch_id, :brand,
    :npvnc, :nvc, :ncdv, :ncc, :ncdc,
    sales_productivity_customers_attributes: [:customer, :_destroy])
  end
end
