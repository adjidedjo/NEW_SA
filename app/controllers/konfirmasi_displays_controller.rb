class KonfirmasiDisplaysController < ApplicationController
  before_action :set_konfirmasi_display, only: [:checked_status, :show, :edit, :update, :destroy]
  before_action :brand, only: [:new, :edit]
  
  def checked_status
    @konfirmasi_display.toggle!(:checked)
    respond_to do |format|
      format.html { redirect_to konfirmasi_display_url, notice: 'Konfirmasi display berhasil dirubah.' }
    end
  end

  # GET /konfirmasi_displays
  # GET /konfirmasi_displays.json
  def index
    @konfirmasi_displays = KonfirmasiDisplay.all
  end

  # GET /konfirmasi_displays/1
  # GET /konfirmasi_displays/1.json
  def show
    @salesman = KonfirmasiDisplay.get_salesman(current_user)
  end

  # GET /konfirmasi_displays/new
  def new
    @konfirmasi_display = KonfirmasiDisplay.new
  end

  # GET /konfirmasi_displays/1/edit
  def edit
    @salesman = KonfirmasiDisplay.get_salesman(current_user)
  end

  # POST /konfirmasi_displays
  # POST /konfirmasi_displays.json
  def create
    @konfirmasi_display = KonfirmasiDisplay.new(konfirmasi_display_params)
    @konfirmasi_display.checked = (current_user.position == 'sales') ? 0 : 1

    respond_to do |format|
      if @konfirmasi_display.save
        format.html { redirect_to new_konfirmasi_display_url, notice: 'Konfirmasi display berhasil dibuat.' }
        format.json { render :show, status: :created, location: @konfirmasi_display }
      else
        format.html { render :new }
        format.json { render json: @konfirmasi_display.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /konfirmasi_displays/1
  # PATCH/PUT /konfirmasi_displays/1.json
  def update
    respond_to do |format|
      if @konfirmasi_display.update(konfirmasi_display_params)
        format.html { redirect_to @konfirmasi_display, notice: 'Konfirmasi display was successfully updated.' }
        format.json { render :show, status: :ok, location: @konfirmasi_display }
      else
        format.html { render :edit }
        format.json { render json: @konfirmasi_display.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /konfirmasi_displays/1
  # DELETE /konfirmasi_displays/1.json
  def destroy
    @konfirmasi_display.destroy
    respond_to do |format|
      format.html { redirect_to konfirmasi_displays_url, notice: 'Konfirmasi display was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  
    def brand
      @salesman = KonfirmasiDisplay.get_salesman(current_user)
      @brand = SalesProductivity.find_by_sql("SELECT jde_brand, id FROM tbbjmerk")
      @customer = KonfirmasiDisplay.get_customer(current_user)  
    end
    
    # Use callbacks to share common setup or constraints between actions.
    def set_konfirmasi_display
      @konfirmasi_display = KonfirmasiDisplay.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def konfirmasi_display_params
      params.require(:konfirmasi_display).permit(:kode_toko, :toko, :kode_sales, :salesman, 
      :brand, :tanggal, :image, :checked)
    end
end
