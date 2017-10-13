class MarketsharesController < ApplicationController
  before_action :set_marketshare, only: [:show, :edit, :update, :destroy]
  before_action :find_brand, only: [:new, :create, :edit, :update, :destroy]
  # GET /marketshares
  # GET /marketshares.json
  def index
    @marketshares = Marketshare.list_customers(current_user)
  end

  # GET /marketshares/1
  # GET /marketshares/1.json
  def show
  end

  # GET /marketshares/new
  def new
    @marketshare = Marketshare.new
  end

  # GET /marketshares/1/edit
  def edit
  end

  # POST /marketshares
  # POST /marketshares.json
  def create
    @marketshare = Marketshare.new(marketshare_params)
    
    respond_to do |format|
      if @marketshare.save
        format.html { redirect_to marketshares_url, notice: 'Marketshare was successfully created.' }
        format.json { render :show, status: :created, location: @marketshare }
      else
        format.html { render :new }
        format.json { render json: @marketshare.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /marketshares/1
  # PATCH/PUT /marketshares/1.json
  def update
    respond_to do |format|
      if @marketshare.update(marketshare_params)
        format.html { redirect_to marketshares_url, notice: 'Marketshare was successfully updated.' }
        format.json { render :show, status: :ok, location: @marketshare }
      else
        format.html { render :edit }
        format.json { render json: @marketshare.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /marketshares/1
  # DELETE /marketshares/1.json
  def destroy
    @marketshare.destroy
    respond_to do |format|
      format.html { redirect_to marketshares_url, notice: 'Marketshare was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def find_brand
    @customer = Customer.where("i_class = 'RET'").group(:name)
    @cities = 
    if current_user.branch1.present?
      IndonesiaCity.where("area_id = '#{current_user.branch1}'").group(:district).order(:district).map{|u| getCity(u.city, u.district).html_safe}
    else
      IndonesiaCity.all.group(:district).order(:district).map{|u| getCity(u.city, u.district).html_safe}
    end
    @ext_brand = Brand.where("external = 1").group(:name)
    @int_brand = Brand.where("external = 0").group(:name)
  end
  
  def getCity(area, district)
   area + " | " + district
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_marketshare
    @marketshare = Marketshare.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def marketshare_params
    params.require(:marketshare).permit(:name, :customer_name, :customer_id, :period_id, 
    :city, :start_date, :end_date, :area_id, :brand,
    marketshare_brands_attributes: [:id, :name, :start_date, :end_date, 
      :amount, :city, :area_id, :internal_brand, :_destroy])
  end
end
