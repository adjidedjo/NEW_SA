class IndonesiaCitiesController < ApplicationController
  before_action :authorize_user
  before_action :set_indonesia_city, only: [:show, :edit, :update, :destroy]
  before_action :set_area, only: [:new, :edit]

  # GET /indonesia_cities
  # GET /indonesia_cities.json
  def index
    @indonesia_cities = IndonesiaCity.all
  end

  # GET /indonesia_cities/1
  # GET /indonesia_cities/1.json
  def show
  end

  # GET /indonesia_cities/new
  def new
    @indonesia_city = IndonesiaCity.new
  end

  # GET /indonesia_cities/1/edit
  def edit
  end

  # POST /indonesia_cities
  # POST /indonesia_cities.json
  def create
    @indonesia_city = IndonesiaCity.new(indonesia_city_params)

    respond_to do |format|
      if @indonesia_city.save
        format.html { redirect_to indonesia_cities_path, notice: 'Kota berhasil dibuat.' }
        format.json { render :show, status: :created, location: @indonesia_city }
      else
        format.html { render :new }
        format.json { render json: @indonesia_city.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /indonesia_cities/1
  # PATCH/PUT /indonesia_cities/1.json
  def update
    respond_to do |format|
      if @indonesia_city.update(indonesia_city_params)
        format.html { redirect_to indonesia_cities_path, notice: 'Kota berhasil dirubah.' }
        format.json { render :show, status: :ok, location: @indonesia_city }
      else
        format.html { render :edit }
        format.json { render json: @indonesia_city.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indonesia_cities/1
  # DELETE /indonesia_cities/1.json
  def destroy
    @indonesia_city.destroy
    respond_to do |format|
      format.html { redirect_to indonesia_cities_url, notice: 'Kota berhasil dihapus.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_indonesia_city
      @indonesia_city = IndonesiaCity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def indonesia_city_params
      params.fetch(:indonesia_city, {}).permit(:id, :name, :area_id)
    end
    
    def set_area
      @area = Area.all
    end
    
    def authorize_user
      render template: "pages/notfound" unless general_manager(current_user)
    end
end
