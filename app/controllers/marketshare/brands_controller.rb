class Marketshare::BrandsController < ApplicationController
  before_action :authorize_user
  before_action :set_marketshare_brand, only: [:show, :edit, :update, :destroy]
  before_action :set_marketshare_brand_type, only: [:new, :edit, :create]
  # GET /marketshare/brands
  # GET /marketshare/brands.json
  def index
    @marketshare_brands = Marketshare::Brand.all.includes(:brand_type)

    respond_to do |format|
      format.html
      format.json { render json: BrandDatatable.new(view_context) }
    end
  end

  # GET /marketshare/brands/1
  # GET /marketshare/brands/1.json
  def show
  end

  # GET /marketshare/brands/new
  def new
    @marketshare_brand = Marketshare::Brand.new
  end

  # GET /marketshare/brands/1/edit
  def edit
  end

  # POST /marketshare/brands
  # POST /marketshare/brands.json
  def create
    @marketshare_brand = Marketshare::Brand.new(marketshare_brand_params)

    respond_to do |format|
      if @marketshare_brand.save
        format.html { redirect_to marketshare_brands_path, notice: 'Brand was successfully created.' }
        format.json { render :show, status: :created, location: @marketshare_brand }
      else
        format.html { render :new }
        format.json { render json: @marketshare_brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /marketshare/brands/1
  # PATCH/PUT /marketshare/brands/1.json
  def update
    respond_to do |format|
      if @marketshare_brand.update(marketshare_brand_params)
        format.html { redirect_to @marketshare_brand, notice: 'Brand was successfully updated.' }
        format.json { render :show, status: :ok, location: @marketshare_brand }
      else
        format.html { render :edit }
        format.json { render json: @marketshare_brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /marketshare/brands/1
  # DELETE /marketshare/brands/1.json
  def destroy
    @marketshare_brand.destroy
    respond_to do |format|
      format.html { redirect_to marketshare_brands_url, notice: 'Brand berhasil dihapus.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_marketshare_brand_type
    @brand_types = Marketshare::BrandType.all
  end

  def authorize_user
    render template: "pages/notfound" if current_user.position == 'admin stock'
  end
  
  def set_marketshare_brand
    @marketshare_brand = Marketshare::Brand.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def marketshare_brand_params
    params.fetch(:marketshare_brand, {}).permit(:name, :brand_type_id, :external)
  end
end
