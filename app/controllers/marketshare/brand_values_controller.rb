class Marketshare::BrandValuesController < ApplicationController
  before_action :authorize_user
  before_action :set_marketshare_brand_value, only: [:show, :edit, :update, :destroy]
  before_action :find_brand, only: [:new, :create]
  # GET /marketshare/brand_values
  # GET /marketshare/brand_values.json
  def index
    get_branch(current_user)
  end

  # GET /marketshare/brand_values/1
  # GET /marketshare/brand_values/1.json
  def show
  end

  # GET /marketshare/brand_values/new
  def new
    @marketshare_brand_value = Marketshare::BrandValue.new
  end

  # GET /marketshare/brand_values/1/edit
  def edit
  end

  # POST /marketshare/brand_values
  # POST /marketshare/brand_values.json
  def create
    @marketshare_brand_value = Marketshare::BrandValue.new(marketshare_brand_value_params)
    @marketshare_brand_value.month = params[:date][:month]
    @marketshare_brand_value.year = params[:date][:year]

    respond_to do |format|
      if @marketshare_brand_value.save
        format.html { redirect_to marketshare_brand_values_path, notice: 'Brand value was successfully created.' }
        format.json { render :show, status: :created, location: @marketshare_brand_value }
      else
        format.html { render :new }
        format.json { render json: @marketshare_brand_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /marketshare/brand_values/1
  # PATCH/PUT /marketshare/brand_values/1.json
  def update
    respond_to do |format|
      if @marketshare_brand_value.update(marketshare_brand_value_params)
        format.html { redirect_to @marketshare_brand_value, notice: 'Brand value was successfully updated.' }
        format.json { render :show, status: :ok, location: @marketshare_brand_value }
      else
        format.html { render :edit }
        format.json { render json: @marketshare_brand_value.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /marketshare/brand_values/1
  # DELETE /marketshare/brand_values/1.json
  def destroy
    @marketshare_brand_value.destroy
    respond_to do |format|
      format.html { redirect_to marketshare_brand_values_url, notice: 'Brand value was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  def get_branch(user)
    if user.position == 'sales'
      @marketshare_brand_values = Marketshare::BrandValue.sales_marketshare_index(current_user)
    elsif user.position == 'bm' || user.position == 'admin sales'
      @marketshare_brand_values = Marketshare::BrandValue.bm_marketshare_index(current_user)
    else
      @marketshare_brand_values = Marketshare::BrandValue.admin_marketshare_index
    end
  end

  def find_brand
    @brands = Marketshare::Brand.all
    @areas = Area.all
    @customer = Customer.where(i_class: 'RET')
  end

  def authorize_user
    render template: "pages/notfound" if current_user.position == 'admin stock'
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_marketshare_brand_value
    @marketshare_brand_value = Marketshare::BrandValue.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def marketshare_brand_value_params
    params.fetch(:marketshare_brand_value, {}).permit(:customer_id, :brand_id, :area_id, :date,
    :month, :year, :amount)
  end
end
