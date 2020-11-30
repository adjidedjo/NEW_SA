require 'test_helper'

class KonfirmasiDisplaysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @konfirmasi_display = konfirmasi_displays(:one)
  end

  test "should get index" do
    get konfirmasi_displays_url
    assert_response :success
  end

  test "should get new" do
    get new_konfirmasi_display_url
    assert_response :success
  end

  test "should create konfirmasi_display" do
    assert_difference('KonfirmasiDisplay.count') do
      post konfirmasi_displays_url, params: { konfirmasi_display: { brand: @konfirmasi_display.brand, image: @konfirmasi_display.image, kode_sales: @konfirmasi_display.kode_sales, kode_toko: @konfirmasi_display.kode_toko, salesman: @konfirmasi_display.salesman, tanggal: @konfirmasi_display.tanggal, toko: @konfirmasi_display.toko } }
    end

    assert_redirected_to konfirmasi_display_url(KonfirmasiDisplay.last)
  end

  test "should show konfirmasi_display" do
    get konfirmasi_display_url(@konfirmasi_display)
    assert_response :success
  end

  test "should get edit" do
    get edit_konfirmasi_display_url(@konfirmasi_display)
    assert_response :success
  end

  test "should update konfirmasi_display" do
    patch konfirmasi_display_url(@konfirmasi_display), params: { konfirmasi_display: { brand: @konfirmasi_display.brand, image: @konfirmasi_display.image, kode_sales: @konfirmasi_display.kode_sales, kode_toko: @konfirmasi_display.kode_toko, salesman: @konfirmasi_display.salesman, tanggal: @konfirmasi_display.tanggal, toko: @konfirmasi_display.toko } }
    assert_redirected_to konfirmasi_display_url(@konfirmasi_display)
  end

  test "should destroy konfirmasi_display" do
    assert_difference('KonfirmasiDisplay.count', -1) do
      delete konfirmasi_display_url(@konfirmasi_display)
    end

    assert_redirected_to konfirmasi_displays_url
  end
end
