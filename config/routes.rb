Rails.application.routes.draw do

  devise_for :users
  # defaults to dashboard
  root :to => 'pages#template'

  # view routes
  # salesman
  get 'penjualan_salesman/daily'
  get 'penjualan_salesman/weekly'
  get 'penjualan_salesman/monthly'
  
  # Bandung
  get 'order/bandung/bandung_elites/order'
  get 'order/bandung/bandung_serenity/order'
  get 'order/bandung/bandung_lady/order'
  get 'order/bandung/bandung_royal/order'

  get 'penjualan/bandung/bandung_elites/weekly'
  get 'penjualan/bandung/bandung_elites/monthly'
  get 'penjualan/bandung/bandung_elites/daily'
  get 'penjualan/bandung/bandung_serenity/weekly'
  get 'penjualan/bandung/bandung_serenity/daily'
  get 'penjualan/bandung/bandung_serenity/monthly'
  get 'penjualan/bandung/bandung_lady/daily'
  get 'penjualan/bandung/bandung_lady/weekly'
  get 'penjualan/bandung/bandung_lady/monthly'
  get 'penjualan/bandung/bandung_royal/daily'
  get 'penjualan/bandung/bandung_royal/weekly'
  get 'penjualan/bandung/bandung_royal/monthly'
  get 'stock/bandung/stock_elite/stock_normal'
  get 'stock/bandung/stock_elite/stock_clearence'
  get 'stock/bandung/stock_elite/stock_service'
  get 'stock/bandung/stock_elite/stock_display'
  get 'stock/bandung/stock_serenity/stock_normal'
  get 'stock/bandung/stock_serenity/stock_clearence'
  get 'stock/bandung/stock_serenity/stock_service'
  get 'stock/bandung/stock_serenity/stock_display'
  get 'stock/bandung/stock_lady/stock_normal'
  get 'stock/bandung/stock_lady/stock_clearence'
  get 'stock/bandung/stock_lady/stock_service'
  get 'stock/bandung/stock_lady/stock_display'
  get 'stock/bandung/stock_royal/stock_normal'
  get 'stock/bandung/stock_royal/stock_clearence'
  get 'stock/bandung/stock_royal/stock_service'
  get 'stock/bandung/stock_royal/stock_display'
  # Cirebon
  get 'order/cirebon/cirebon_elites/order'
  get 'order/cirebon/cirebon_serenity/order'
  get 'order/cirebon/cirebon_lady/order'
  get 'order/cirebon/cirebon_royal/order'
  get 'penjualan/cirebon/cirebon_elites/daily'
  get 'penjualan/cirebon/cirebon_elites/weekly'
  get 'penjualan/cirebon/cirebon_elites/monthly'
  get 'penjualan/cirebon/cirebon_serenity/daily'
  get 'penjualan/cirebon/cirebon_serenity/weekly'
  get 'penjualan/cirebon/cirebon_serenity/monthly'
  get 'penjualan/cirebon/cirebon_lady/daily'
  get 'penjualan/cirebon/cirebon_lady/weekly'
  get 'penjualan/cirebon/cirebon_lady/monthly'
  get 'penjualan/cirebon/cirebon_royal/daily'
  get 'penjualan/cirebon/cirebon_royal/weekly'
  get 'penjualan/cirebon/cirebon_royal/monthly'
  get 'stock/cirebon/stock_elite/stock_normal'
  get 'stock/cirebon/stock_elite/stock_clearence'
  get 'stock/cirebon/stock_elite/stock_service'
  get 'stock/cirebon/stock_elite/stock_display'
  get 'stock/cirebon/stock_serenity/stock_normal'
  get 'stock/cirebon/stock_serenity/stock_clearence'
  get 'stock/cirebon/stock_serenity/stock_service'
  get 'stock/cirebon/stock_serenity/stock_display'
  get 'stock/cirebon/stock_lady/stock_normal'
  get 'stock/cirebon/stock_lady/stock_clearence'
  get 'stock/cirebon/stock_lady/stock_service'
  get 'stock/cirebon/stock_lady/stock_display'
  get 'stock/cirebon/stock_royal/stock_normal'
  get 'stock/cirebon/stock_royal/stock_clearence'
  get 'stock/cirebon/stock_royal/stock_service'
  get 'stock/cirebon/stock_royal/stock_display'
  # Bekasi
  get 'order/bekasi/bekasi_elites/order'
  get 'order/bekasi/bekasi_serenity/order'
  get 'order/bekasi/bekasi_lady/order'
  get 'order/bekasi/bekasi_royal/order'
  get 'penjualan/bekasi/bekasi_elites/daily'
  get 'penjualan/bekasi/bekasi_elites/weekly'
  get 'penjualan/bekasi/bekasi_elites/monthly'
  get 'penjualan/bekasi/bekasi_serenity/daily'
  get 'penjualan/bekasi/bekasi_serenity/weekly'
  get 'penjualan/bekasi/bekasi_serenity/monthly'
  get 'penjualan/bekasi/bekasi_lady/daily'
  get 'penjualan/bekasi/bekasi_lady/weekly'
  get 'penjualan/bekasi/bekasi_lady/monthly'
  get 'penjualan/bekasi/bekasi_royal/daily'
  get 'penjualan/bekasi/bekasi_royal/weekly'
  get 'penjualan/bekasi/bekasi_royal/monthly'
  get 'stock/bekasi/stock_elite/stock_normal'
  get 'stock/bekasi/stock_elite/stock_clearence'
  get 'stock/bekasi/stock_elite/stock_service'
  get 'stock/bekasi/stock_elite/stock_display'
  get 'stock/bekasi/stock_serenity/stock_normal'
  get 'stock/bekasi/stock_serenity/stock_clearence'
  get 'stock/bekasi/stock_serenity/stock_service'
  get 'stock/bekasi/stock_serenity/stock_display'
  get 'stock/bekasi/stock_lady/stock_normal'
  get 'stock/bekasi/stock_lady/stock_clearence'
  get 'stock/bekasi/stock_lady/stock_service'
  get 'stock/bekasi/stock_lady/stock_display'
  get 'stock/bekasi/stock_royal/stock_normal'
  get 'stock/bekasi/stock_royal/stock_clearence'
  get 'stock/bekasi/stock_royal/stock_service'
  get 'stock/bekasi/stock_royal/stock_display'
  # Tangerang
  get 'order/tangerang/tangerang_elites/order'
  get 'order/tangerang/tangerang_serenity/order'
  get 'order/tangerang/tangerang_lady/order'
  get 'order/tangerang/tangerang_royal/order'
  get 'penjualan/tangerang/tangerang_elites/daily'
  get 'penjualan/tangerang/tangerang_elites/weekly'
  get 'penjualan/tangerang/tangerang_elites/monthly'
  get 'penjualan/tangerang/tangerang_serenity/daily'
  get 'penjualan/tangerang/tangerang_serenity/weekly'
  get 'penjualan/tangerang/tangerang_serenity/monthly'
  get 'penjualan/tangerang/tangerang_lady/daily'
  get 'penjualan/tangerang/tangerang_lady/weekly'
  get 'penjualan/tangerang/tangerang_lady/monthly'
  get 'penjualan/tangerang/tangerang_royal/daily'
  get 'penjualan/tangerang/tangerang_royal/weekly'
  get 'penjualan/tangerang/tangerang_royal/monthly'
  get 'stock/tangerang/stock_elite/stock_normal'
  get 'stock/tangerang/stock_elite/stock_clearence'
  get 'stock/tangerang/stock_elite/stock_service'
  get 'stock/tangerang/stock_elite/stock_display'
  get 'stock/tangerang/stock_serenity/stock_normal'
  get 'stock/tangerang/stock_serenity/stock_clearence'
  get 'stock/tangerang/stock_serenity/stock_service'
  get 'stock/tangerang/stock_serenity/stock_display'
  get 'stock/tangerang/stock_lady/stock_normal'
  get 'stock/tangerang/stock_lady/stock_clearence'
  get 'stock/tangerang/stock_lady/stock_service'
  get 'stock/tangerang/stock_lady/stock_display'
  get 'stock/tangerang/stock_royal/stock_normal'
  get 'stock/tangerang/stock_royal/stock_clearence'
  get 'stock/tangerang/stock_royal/stock_service'
  get 'stock/tangerang/stock_royal/stock_display'
  # Surabaya
  get 'order/surabaya/surabaya_elites/order'
  get 'order/surabaya/surabaya_serenity/order'
  get 'order/surabaya/surabaya_lady/order'
  get 'order/surabaya/surabaya_royal/order'
  get 'penjualan/surabaya/surabaya_elites/daily'
  get 'penjualan/surabaya/surabaya_elites/weekly'
  get 'penjualan/surabaya/surabaya_elites/monthly'
  get 'penjualan/surabaya/surabaya_serenity/daily'
  get 'penjualan/surabaya/surabaya_serenity/weekly'
  get 'penjualan/surabaya/surabaya_serenity/monthly'
  get 'penjualan/surabaya/surabaya_lady/daily'
  get 'penjualan/surabaya/surabaya_lady/weekly'
  get 'penjualan/surabaya/surabaya_lady/monthly'
  get 'penjualan/surabaya/surabaya_royal/daily'
  get 'penjualan/surabaya/surabaya_royal/weekly'
  get 'penjualan/surabaya/surabaya_royal/monthly'
  get 'stock/surabaya/stock_elite/stock_normal'
  get 'stock/surabaya/stock_elite/stock_clearence'
  get 'stock/surabaya/stock_elite/stock_service'
  get 'stock/surabaya/stock_elite/stock_display'
  get 'stock/surabaya/stock_serenity/stock_normal'
  get 'stock/surabaya/stock_serenity/stock_clearence'
  get 'stock/surabaya/stock_serenity/stock_service'
  get 'stock/surabaya/stock_serenity/stock_display'
  get 'stock/surabaya/stock_lady/stock_normal'
  get 'stock/surabaya/stock_lady/stock_clearence'
  get 'stock/surabaya/stock_lady/stock_service'
  get 'stock/surabaya/stock_lady/stock_display'
  get 'stock/surabaya/stock_royal/stock_normal'
  get 'stock/surabaya/stock_royal/stock_clearence'
  get 'stock/surabaya/stock_royal/stock_service'
  get 'stock/surabaya/stock_royal/stock_display'
  # Bali
  get 'order/bali/bali_elites/order'
  get 'order/bali/bali_serenity/order'
  get 'order/bali/bali_lady/order'
  get 'order/bali/bali_royal/order'
  get 'penjualan/bali/bali_elites/daily'
  get 'penjualan/bali/bali_elites/weekly'
  get 'penjualan/bali/bali_elites/monthly'
  get 'penjualan/bali/bali_serenity/daily'
  get 'penjualan/bali/bali_serenity/weekly'
  get 'penjualan/bali/bali_serenity/monthly'
  get 'penjualan/bali/bali_lady/daily'
  get 'penjualan/bali/bali_lady/weekly'
  get 'penjualan/bali/bali_lady/monthly'
  get 'penjualan/bali/bali_royal/daily'
  get 'penjualan/bali/bali_royal/weekly'
  get 'penjualan/bali/bali_royal/monthly'
  get 'stock/bali/stock_elite/stock_normal'
  get 'stock/bali/stock_elite/stock_clearence'
  get 'stock/bali/stock_elite/stock_service'
  get 'stock/bali/stock_elite/stock_display'
  get 'stock/bali/stock_serenity/stock_normal'
  get 'stock/bali/stock_serenity/stock_clearence'
  get 'stock/bali/stock_serenity/stock_service'
  get 'stock/bali/stock_serenity/stock_display'
  get 'stock/bali/stock_lady/stock_normal'
  get 'stock/bali/stock_lady/stock_clearence'
  get 'stock/bali/stock_lady/stock_service'
  get 'stock/bali/stock_lady/stock_display'
  get 'stock/bali/stock_royal/stock_normal'
  get 'stock/bali/stock_royal/stock_clearence'
  get 'stock/bali/stock_royal/stock_service'
  get 'stock/bali/stock_royal/stock_display'
  # Makasar
  get 'order/makasar/makasar_elites/order'
  get 'order/makasar/makasar_serenity/order'
  get 'order/makasar/makasar_lady/order'
  get 'order/makasar/makasar_royal/order'
  get 'penjualan/makasar/makasar_elites/daily'
  get 'penjualan/makasar/makasar_elites/weekly'
  get 'penjualan/makasar/makasar_elites/monthly'
  get 'penjualan/makasar/makasar_serenity/daily'
  get 'penjualan/makasar/makasar_serenity/weekly'
  get 'penjualan/makasar/makasar_serenity/monthly'
  get 'penjualan/makasar/makasar_lady/daily'
  get 'penjualan/makasar/makasar_lady/weekly'
  get 'penjualan/makasar/makasar_lady/monthly'
  get 'penjualan/makasar/makasar_royal/daily'
  get 'penjualan/makasar/makasar_royal/weekly'
  get 'penjualan/makasar/makasar_royal/monthly'
  get 'stock/makasar/stock_elite/stock_normal'
  get 'stock/makasar/stock_elite/stock_clearence'
  get 'stock/makasar/stock_elite/stock_service'
  get 'stock/makasar/stock_elite/stock_display'
  get 'stock/makasar/stock_serenity/stock_normal'
  get 'stock/makasar/stock_serenity/stock_clearence'
  get 'stock/makasar/stock_serenity/stock_service'
  get 'stock/makasar/stock_serenity/stock_display'
  get 'stock/makasar/stock_lady/stock_normal'
  get 'stock/makasar/stock_lady/stock_clearence'
  get 'stock/makasar/stock_lady/stock_service'
  get 'stock/makasar/stock_lady/stock_display'
  get 'stock/makasar/stock_royal/stock_normal'
  get 'stock/makasar/stock_royal/stock_clearence'
  get 'stock/makasar/stock_royal/stock_service'
  get 'stock/makasar/stock_royal/stock_display'
  # Jember
  get 'order/jember/jember_elites/order'
  get 'order/jember/jember_serenity/order'
  get 'order/jember/jember_lady/order'
  get 'order/jember/jember_royal/order'
  get 'penjualan/jember/jember_elites/daily'
  get 'penjualan/jember/jember_elites/weekly'
  get 'penjualan/jember/jember_elites/monthly'
  get 'penjualan/jember/jember_serenity/daily'
  get 'penjualan/jember/jember_serenity/weekly'
  get 'penjualan/jember/jember_serenity/monthly'
  get 'penjualan/jember/jember_lady/daily'
  get 'penjualan/jember/jember_lady/weekly'
  get 'penjualan/jember/jember_lady/monthly'
  get 'penjualan/jember/jember_royal/daily'
  get 'penjualan/jember/jember_royal/weekly'
  get 'penjualan/jember/jember_royal/monthly'
  get 'stock/jember/stock_elite/stock_normal'
  get 'stock/jember/stock_elite/stock_clearence'
  get 'stock/jember/stock_elite/stock_service'
  get 'stock/jember/stock_elite/stock_display'
  get 'stock/jember/stock_serenity/stock_normal'
  get 'stock/jember/stock_serenity/stock_clearence'
  get 'stock/jember/stock_serenity/stock_service'
  get 'stock/jember/stock_serenity/stock_display'
  get 'stock/jember/stock_lady/stock_normal'
  get 'stock/jember/stock_lady/stock_clearence'
  get 'stock/jember/stock_lady/stock_service'
  get 'stock/jember/stock_lady/stock_display'
  get 'stock/jember/stock_royal/stock_normal'
  get 'stock/jember/stock_royal/stock_clearence'
  get 'stock/jember/stock_royal/stock_service'
  get 'stock/jember/stock_royal/stock_display'
  # Lampung
  get 'order/lampung/lampung_elites/order'
  get 'order/lampung/lampung_serenity/order'
  get 'order/lampung/lampung_lady/order'
  get 'order/lampung/lampung_royal/order'
  get 'penjualan/lampung/lampung_elites/daily'
  get 'penjualan/lampung/lampung_elites/weekly'
  get 'penjualan/lampung/lampung_elites/monthly'
  get 'penjualan/lampung/lampung_serenity/daily'
  get 'penjualan/lampung/lampung_serenity/weekly'
  get 'penjualan/lampung/lampung_serenity/monthly'
  get 'penjualan/lampung/lampung_lady/daily'
  get 'penjualan/lampung/lampung_lady/weekly'
  get 'penjualan/lampung/lampung_lady/monthly'
  get 'penjualan/lampung/lampung_royal/daily'
  get 'penjualan/lampung/lampung_royal/weekly'
  get 'penjualan/lampung/lampung_royal/monthly'
  get 'stock/lampung/stock_elite/stock_normal'
  get 'stock/lampung/stock_elite/stock_clearence'
  get 'stock/lampung/stock_elite/stock_service'
  get 'stock/lampung/stock_elite/stock_display'
  get 'stock/lampung/stock_serenity/stock_normal'
  get 'stock/lampung/stock_serenity/stock_clearence'
  get 'stock/lampung/stock_serenity/stock_service'
  get 'stock/lampung/stock_serenity/stock_display'
  get 'stock/lampung/stock_lady/stock_normal'
  get 'stock/lampung/stock_lady/stock_clearence'
  get 'stock/lampung/stock_lady/stock_service'
  get 'stock/lampung/stock_lady/stock_display'
  get 'stock/lampung/stock_royal/stock_normal'
  get 'stock/lampung/stock_royal/stock_clearence'
  get 'stock/lampung/stock_royal/stock_service'
  get 'stock/lampung/stock_royal/stock_display'
  # Palembang
  get 'order/palembang/palembang_elites/order'
  get 'order/palembang/palembang_serenity/order'
  get 'order/palembang/palembang_lady/order'
  get 'order/palembang/palembang_royal/order'
  get 'penjualan/palembang/palembang_elites/daily'
  get 'penjualan/palembang/palembang_elites/weekly'
  get 'penjualan/palembang/palembang_elites/monthly'
  get 'penjualan/palembang/palembang_serenity/daily'
  get 'penjualan/palembang/palembang_serenity/weekly'
  get 'penjualan/palembang/palembang_serenity/monthly'
  get 'penjualan/palembang/palembang_lady/daily'
  get 'penjualan/palembang/palembang_lady/weekly'
  get 'penjualan/palembang/palembang_lady/monthly'
  get 'penjualan/palembang/palembang_royal/daily'
  get 'penjualan/palembang/palembang_royal/weekly'
  get 'penjualan/palembang/palembang_royal/monthly'
  get 'stock/palembang/stock_elite/stock_normal'
  get 'stock/palembang/stock_elite/stock_clearence'
  get 'stock/palembang/stock_elite/stock_service'
  get 'stock/palembang/stock_elite/stock_display'
  get 'stock/palembang/stock_serenity/stock_normal'
  get 'stock/palembang/stock_serenity/stock_clearence'
  get 'stock/palembang/stock_serenity/stock_service'
  get 'stock/palembang/stock_serenity/stock_display'
  get 'stock/palembang/stock_lady/stock_normal'
  get 'stock/palembang/stock_lady/stock_clearence'
  get 'stock/palembang/stock_lady/stock_service'
  get 'stock/palembang/stock_lady/stock_display'
  get 'stock/palembang/stock_royal/stock_normal'
  get 'stock/palembang/stock_royal/stock_clearence'
  get 'stock/palembang/stock_royal/stock_service'
  get 'stock/palembang/stock_royal/stock_display'
  # Semarang
  get 'order/semarang/semarang_elites/order'
  get 'order/semarang/semarang_serenity/order'
  get 'order/semarang/semarang_lady/order'
  get 'order/semarang/semarang_royal/order'
  get 'penjualan/semarang/semarang_elites/daily'
  get 'penjualan/semarang/semarang_elites/weekly'
  get 'penjualan/semarang/semarang_elites/monthly'
  get 'penjualan/semarang/semarang_serenity/daily'
  get 'penjualan/semarang/semarang_serenity/weekly'
  get 'penjualan/semarang/semarang_serenity/monthly'
  get 'penjualan/semarang/semarang_lady/daily'
  get 'penjualan/semarang/semarang_lady/weekly'
  get 'penjualan/semarang/semarang_lady/monthly'
  get 'penjualan/semarang/semarang_royal/daily'
  get 'penjualan/semarang/semarang_royal/weekly'
  get 'penjualan/semarang/semarang_royal/monthly'
  get 'stock/semarang/stock_elite/stock_normal'
  get 'stock/semarang/stock_elite/stock_clearence'
  get 'stock/semarang/stock_elite/stock_service'
  get 'stock/semarang/stock_elite/stock_display'
  get 'stock/semarang/stock_serenity/stock_normal'
  get 'stock/semarang/stock_serenity/stock_clearence'
  get 'stock/semarang/stock_serenity/stock_service'
  get 'stock/semarang/stock_serenity/stock_display'
  get 'stock/semarang/stock_lady/stock_normal'
  get 'stock/semarang/stock_lady/stock_clearence'
  get 'stock/semarang/stock_lady/stock_service'
  get 'stock/semarang/stock_lady/stock_display'
  get 'stock/semarang/stock_royal/stock_normal'
  get 'stock/semarang/stock_royal/stock_clearence'
  get 'stock/semarang/stock_royal/stock_service'
  get 'stock/semarang/stock_royal/stock_display'
  # Yogyakarta
  get 'order/yogya/yogya_elites/order'
  get 'order/yogya/yogya_serenity/order'
  get 'order/yogya/yogya_lady/order'
  get 'order/yogya/yogya_royal/order'
  get 'penjualan/yogya/yogya_elites/daily'
  get 'penjualan/yogya/yogya_elites/weekly'
  get 'penjualan/yogya/yogya_elites/monthly'
  get 'penjualan/yogya/yogya_serenity/daily'
  get 'penjualan/yogya/yogya_serenity/weekly'
  get 'penjualan/yogya/yogya_serenity/monthly'
  get 'penjualan/yogya/yogya_lady/daily'
  get 'penjualan/yogya/yogya_lady/weekly'
  get 'penjualan/yogya/yogya_lady/monthly'
  get 'penjualan/yogya/yogya_royal/daily'
  get 'penjualan/yogya/yogya_royal/weekly'
  get 'penjualan/yogya/yogya_royal/monthly'
  get 'stock/yogya/stock_elite/stock_normal'
  get 'stock/yogya/stock_elite/stock_clearence'
  get 'stock/yogya/stock_elite/stock_service'
  get 'stock/yogya/stock_elite/stock_display'
  get 'stock/yogya/stock_serenity/stock_normal'
  get 'stock/yogya/stock_serenity/stock_clearence'
  get 'stock/yogya/stock_serenity/stock_service'
  get 'stock/yogya/stock_serenity/stock_display'
  get 'stock/yogya/stock_lady/stock_normal'
  get 'stock/yogya/stock_lady/stock_clearence'
  get 'stock/yogya/stock_lady/stock_service'
  get 'stock/yogya/stock_lady/stock_display'
  get 'stock/yogya/stock_royal/stock_normal'
  get 'stock/yogya/stock_royal/stock_clearence'
  get 'stock/yogya/stock_royal/stock_service'
  get 'stock/yogya/stock_royal/stock_display'
  # Medan
  get 'order/medan/medan_elites/order'
  get 'order/medan/medan_serenity/order'
  get 'order/medan/medan_lady/order'
  get 'order/medan/medan_royal/order'
  get 'penjualan/medan/medan_elites/daily'
  get 'penjualan/medan/medan_elites/weekly'
  get 'penjualan/medan/medan_elites/monthly'
  get 'penjualan/medan/medan_serenity/daily'
  get 'penjualan/medan/medan_serenity/weekly'
  get 'penjualan/medan/medan_serenity/monthly'
  get 'penjualan/medan/medan_lady/daily'
  get 'penjualan/medan/medan_lady/weekly'
  get 'penjualan/medan/medan_lady/monthly'
  get 'penjualan/medan/medan_royal/daily'
  get 'penjualan/medan/medan_royal/weekly'
  get 'penjualan/medan/medan_royal/monthly'
  get 'stock/medan/stock_elite/stock_normal'
  get 'stock/medan/stock_elite/stock_clearence'
  get 'stock/medan/stock_elite/stock_service'
  get 'stock/medan/stock_elite/stock_display'
  get 'stock/medan/stock_serenity/stock_normal'
  get 'stock/medan/stock_serenity/stock_clearence'
  get 'stock/medan/stock_serenity/stock_service'
  get 'stock/medan/stock_serenity/stock_display'
  get 'stock/medan/stock_lady/stock_normal'
  get 'stock/medan/stock_lady/stock_clearence'
  get 'stock/medan/stock_lady/stock_service'
  get 'stock/medan/stock_lady/stock_display'
  get 'stock/medan/stock_royal/stock_normal'
  get 'stock/medan/stock_royal/stock_clearence'
  get 'stock/medan/stock_royal/stock_service'
  get 'stock/medan/stock_royal/stock_display'
  # Pekanbaru
  get 'order/pekanbaru/pekanbaru_elites/order'
  get 'order/pekanbaru/pekanbaru_serenity/order'
  get 'order/pekanbaru/pekanbaru_lady/order'
  get 'order/pekanbaru/pekanbaru_royal/order'
  get 'penjualan/pekanbaru/pekanbaru_elites/daily'
  get 'penjualan/pekanbaru/pekanbaru_elites/weekly'
  get 'penjualan/pekanbaru/pekanbaru_elites/monthly'
  get 'penjualan/pekanbaru/pekanbaru_serenity/daily'
  get 'penjualan/pekanbaru/pekanbaru_serenity/weekly'
  get 'penjualan/pekanbaru/pekanbaru_serenity/monthly'
  get 'penjualan/pekanbaru/pekanbaru_lady/daily'
  get 'penjualan/pekanbaru/pekanbaru_lady/weekly'
  get 'penjualan/pekanbaru/pekanbaru_lady/monthly'
  get 'penjualan/pekanbaru/pekanbaru_royal/daily'
  get 'penjualan/pekanbaru/pekanbaru_royal/weekly'
  get 'penjualan/pekanbaru/pekanbaru_royal/monthly'
  get 'stock/pekanbaru/stock_elite/stock_normal'
  get 'stock/pekanbaru/stock_elite/stock_clearence'
  get 'stock/pekanbaru/stock_elite/stock_service'
  get 'stock/pekanbaru/stock_elite/stock_display'
  get 'stock/pekanbaru/stock_serenity/stock_normal'
  get 'stock/pekanbaru/stock_serenity/stock_clearence'
  get 'stock/pekanbaru/stock_serenity/stock_service'
  get 'stock/pekanbaru/stock_serenity/stock_display'
  get 'stock/pekanbaru/stock_lady/stock_normal'
  get 'stock/pekanbaru/stock_lady/stock_clearence'
  get 'stock/pekanbaru/stock_lady/stock_service'
  get 'stock/pekanbaru/stock_lady/stock_display'
  get 'stock/pekanbaru/stock_royal/stock_normal'
  get 'stock/pekanbaru/stock_royal/stock_clearence'
  get 'stock/pekanbaru/stock_royal/stock_service'
  get 'stock/pekanbaru/stock_royal/stock_display'
  # get 'penjualan/bandung/elite/weekly'
  # get 'penjualan/bandung/monthly'
  # get 'penjualan/bandung/yearly'

  get '/widgets' => 'widgets#index'
  get '/documentation' => 'documentation#index'

  get 'dashboard/dashboard_v1'
  get 'dashboard/dashboard_v2'
  get 'dashboard/dashboard_v3'
  get 'dashboard/dashboard_h'
  get 'elements/button'
  get 'elements/notification'
  get 'elements/spinner'
  get 'elements/animation'
  get 'elements/dropdown'
  get 'elements/nestable'
  get 'elements/sortable'
  get 'elements/panel'
  get 'elements/portlet'
  get 'elements/grid'
  get 'elements/gridmasonry'
  get 'elements/typography'
  get 'elements/fonticons'
  get 'elements/weathericons'
  get 'elements/colors'
  get 'elements/buttons'
  get 'elements/notifications'
  get 'elements/carousel'
  get 'elements/tour'
  get 'elements/sweetalert'
  get 'forms/standard'
  get 'forms/extended'
  get 'forms/validation'
  get 'forms/wizard'
  get 'forms/upload'
  get 'forms/xeditable'
  get 'forms/imgcrop'
  get 'multilevel/level1'
  get 'multilevel/level3'
  get 'charts/flot'
  get 'charts/radial'
  get 'charts/chartjs'
  get 'charts/chartist'
  get 'charts/morris'
  get 'charts/rickshaw'
  get 'tables/standard'
  get 'tables/extended'
  get 'tables/datatable'
  get 'tables/jqgrid'
  get 'maps/google'
  get 'maps/vector'
  get 'extras/mailbox'
  get 'extras/timeline'
  get 'extras/calendar'
  get 'extras/invoice'
  get 'extras/search'
  get 'extras/todo'
  get 'extras/profile'
  get 'extras/contacts'
  get 'extras/contact_details'
  get 'extras/projects'
  get 'extras/project_details'
  get 'extras/team_viewer'
  get 'extras/social_board'
  get 'extras/vote_links'
  get 'extras/bug_tracker'
  get 'extras/faq'
  get 'extras/help_center'
  get 'extras/followers'
  get 'extras/settings'
  get 'extras/plans'
  get 'extras/file_manager'
  get 'blog/blog'
  get 'blog/blog_post'
  get 'blog/blog_articles'
  get 'blog/blog_article_view'
  get 'ecommerce/ecommerce_orders'
  get 'ecommerce/ecommerce_order_view'
  get 'ecommerce/ecommerce_products'
  get 'ecommerce/ecommerce_product_view'
  get 'ecommerce/ecommerce_checkout'
  get 'forum/forum_categories'
  get 'forum/forum_topics'
  get 'forum/forum_discussion'
  get 'pages/login'
  get 'pages/register'
  get 'pages/recover'
  get 'pages/lock'
  get 'pages/template'
  get 'pages/notfound'
  get 'pages/maintenance'
  get 'pages/error500'

  # api routes
  get '/api/documentation' => 'api#documentation'
  get '/api/datatable' => 'api#datatable'
  get '/api/jqgrid' => 'api#jqgrid'
  get '/api/jqgridtree' => 'api#jqgridtree'
  get '/api/i18n/:locale' => 'api#i18n'
  post '/api/xeditable' => 'api#xeditable'
  get '/api/xeditable-groups' => 'api#xeditablegroups'

  # the rest goes to root
  get '*path' => redirect('/')
end
