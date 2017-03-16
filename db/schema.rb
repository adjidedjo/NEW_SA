# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170314114804) do

  create_table "branch_incentives", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "position_incentive_id"
    t.integer "range_incentive_id"
    t.decimal "value_percentage",                precision: 11, scale: 5
    t.string  "product_id",            limit: 3
  end

  create_table "brand_products", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "product_id"
    t.string "merk_id",    limit: 20
  end

  create_table "channel_customers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "channel",    limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checked_item_masters", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.date    "tgl_faktur"
    t.string  "nofaktur",           limit: 50
    t.integer "cabang_id"
    t.string  "customer"
    t.string  "kodebarang",         limit: 50
    t.string  "namabarang",         limit: 100
    t.string  "panjang",            limit: 3
    t.string  "lebar",              limit: 3
    t.integer "quantity"
    t.decimal "harga_master",                   precision: 10
    t.decimal "harga_laporan",                  precision: 10
    t.decimal "upgrade_master",                 precision: 10
    t.decimal "upgrade_laporan",                precision: 10
    t.decimal "cashback_master",                precision: 10
    t.decimal "cashback_laporan",               precision: 10
    t.integer "discount_1_master"
    t.integer "discount_1_laporan"
    t.integer "discount_2_master"
    t.integer "discount_2_laporan"
    t.integer "discount_3_master",                             default: 0
    t.integer "discount_3_laporan",                            default: 0
    t.integer "discount_4_master",                             default: 0
    t.integer "discount_4_laporan",                            default: 0
    t.boolean "checked",                                       default: false
    t.boolean "customer_services",                             default: false
    t.date    "tanggal"
    t.string  "bonus",              limit: 50
    t.decimal "netto2",                         precision: 10
    t.string  "no_so"
    t.string  "no_po"
    t.decimal "total_netto2",                   precision: 10, default: 0
  end

  create_table "comparison_between_months", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "branch"
    t.string  "brand",      limit: 50
    t.bigint  "qty_month"
    t.decimal "val_month",             precision: 10
    t.date    "first_day"
    t.date    "latest_day"
  end

  create_table "cost_of_goods", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "produk",            limit: 10
    t.string   "merk"
    t.string   "artikel"
    t.string   "ukuran"
    t.integer  "cabang_id"
    t.string   "customer"
    t.integer  "margin1"
    t.integer  "margin2"
    t.integer  "margin3"
    t.integer  "margin4"
    t.integer  "margin5"
    t.decimal  "margin_percent",               precision: 10
    t.decimal  "price_list",                   precision: 10
    t.integer  "diskon1"
    t.integer  "diskon2"
    t.decimal  "net_a_diskon",                 precision: 10
    t.decimal  "paket",                        precision: 10
    t.integer  "top"
    t.decimal  "net_a_top",                    precision: 10
    t.decimal  "central",                      precision: 10
    t.decimal  "poin",                         precision: 10
    t.decimal  "net_a_poin",                   precision: 10
    t.integer  "kontrak"
    t.decimal  "net_a_kontrak",                precision: 10
    t.integer  "lrv"
    t.decimal  "net_a_lrv",                    precision: 10
    t.decimal  "incentive_sales",              precision: 10, scale: 3
    t.decimal  "incentive_sales_m",            precision: 10
    t.decimal  "total_bonus",                  precision: 10
    t.decimal  "ongkir",                       precision: 10
    t.decimal  "hpp",                          precision: 10
    t.decimal  "b_mkt",                        precision: 10, scale: 3
    t.decimal  "b_mkt_m",                      precision: 10
    t.decimal  "bhbo",                         precision: 10
    t.decimal  "margin_m",                     precision: 10
    t.integer  "margin"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "point",                        precision: 15, scale: 10
    t.decimal  "net_a_incentive",              precision: 10, scale: 3
  end

  create_table "cost_of_items", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string  "kodebarang", limit: 50
    t.string  "namabarang", limit: 250
    t.decimal "hpp",                    precision: 10, scale: 2
  end

  create_table "customers", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "cabang_id",                      default: 0
    t.string  "kode_customer",    limit: 50,    default: "0"
    t.string  "nama_customer",    limit: 250
    t.text    "alamat",           limit: 65535
    t.string  "kota",             limit: 50
    t.string  "area",             limit: 50
    t.string  "tipe_customer",    limit: 250
    t.string  "group_customer",   limit: 250
    t.string  "flankin_customer", limit: 250
    t.index ["kode_customer", "nama_customer"], name: "customer", using: :btree
  end

  create_table "daily_sales", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "bulan"
    t.string   "tahun"
    t.string   "brand"
    t.integer  "cabang_id"
    t.string   "tipe"
    t.integer  "day01",      default: 0
    t.integer  "day02",      default: 0
    t.integer  "day03",      default: 0
    t.integer  "day04",      default: 0
    t.integer  "day05",      default: 0
    t.integer  "day06",      default: 0
    t.integer  "day07",      default: 0
    t.integer  "day08",      default: 0
    t.integer  "day09",      default: 0
    t.integer  "day10",      default: 0
    t.integer  "day11",      default: 0
    t.integer  "day12",      default: 0
    t.integer  "day13",      default: 0
    t.integer  "day14",      default: 0
    t.integer  "day15",      default: 0
    t.integer  "day16",      default: 0
    t.integer  "day17",      default: 0
    t.integer  "day18",      default: 0
    t.integer  "day19",      default: 0
    t.integer  "day20",      default: 0
    t.integer  "day21",      default: 0
    t.integer  "day22",      default: 0
    t.integer  "day23",      default: 0
    t.integer  "day24",      default: 0
    t.integer  "day25",      default: 0
    t.integer  "day26",      default: 0
    t.integer  "day27",      default: 0
    t.integer  "day28",      default: 0
    t.integer  "day29",      default: 0
    t.integer  "day30",      default: 0
    t.integer  "day31",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "django_migrations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "app",     null: false
    t.string   "name",    null: false
    t.datetime "applied", null: false
  end

  create_table "do_customers", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string  "address_number", limit: 20
    t.string  "name",           limit: 50
    t.string  "brand",          limit: 1
    t.integer "cabang_id"
    t.decimal "commitment",                precision: 10
    t.date    "from"
    t.date    "to"
  end

  create_table "find_barcodes", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "serial", limit: 30
    t.string "kode",   limit: 30
    t.string "nama",   limit: 100
    t.string "kode2",  limit: 30
  end

  create_table "forecasts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "cabang_id"
    t.integer  "bulan"
    t.integer  "tahun"
    t.string   "kode_forecast"
    t.string   "artikel"
    t.string   "kain"
    t.integer  "jumlah"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "future_price_lists", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "cabang_id"
    t.string   "kode_barang"
    t.string   "nama"
    t.integer  "brand_id"
    t.string   "jenis"
    t.string   "produk"
    t.string   "kain"
    t.string   "panjang"
    t.string   "lebar"
    t.decimal  "harga",                     precision: 10
    t.date     "harga_starting_at"
    t.integer  "discount_1"
    t.integer  "discount_2"
    t.integer  "discount_3"
    t.integer  "discount_4"
    t.date     "discount_starting_at"
    t.decimal  "upgrade",                   precision: 10
    t.date     "upgrade_starting_at"
    t.decimal  "cashback",                  precision: 10
    t.date     "cashback_starting_at"
    t.decimal  "special_price",             precision: 10
    t.date     "special_price_starting_at"
    t.integer  "regional_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "goods_heritages", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint   "parent_item_id"
    t.bigint   "child_item_id"
    t.string   "parent_kodebarang",   limit: 100
    t.string   "child_kodebarang",    limit: 100
    t.float    "next_upgrade",        limit: 24,  default: 0.0
    t.float    "upgrade",             limit: 24,  default: 0.0
    t.integer  "next_diskon4",                    default: 0
    t.integer  "diskon4",                         default: 0
    t.integer  "next_diskon5",                    default: 0
    t.integer  "diskon5",                         default: 0
    t.integer  "next_diskon6",                    default: 0
    t.integer  "diskon6",                         default: 0
    t.float    "next_cashback",       limit: 24,  default: 0.0
    t.float    "cashback",            limit: 24,  default: 0.0
    t.datetime "program_starting_at"
  end

  create_table "group_forecasts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "kode_barang"
    t.string   "kode_forecast"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "item_statuses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "n_status"
    t.string   "s_status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items_pos", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string  "kode_barang"
    t.string  "nama"
    t.integer "brand_id"
    t.string  "jenis",       limit: 10
    t.decimal "harga",                  precision: 10
  end

  create_table "modern_market", primary_key: "INCC", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "NAMA",     limit: 50
    t.string "KATEGORI", limit: 15
    t.string "CABANG",   limit: 15
  end

  create_table "monthly_retails", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "monthly_targets_id"
    t.datetime "from_period"
    t.datetime "to_period"
    t.decimal  "total",              precision: 10
    t.integer  "cabang_id"
    t.integer  "brand_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "customer"
  end

  create_table "monthly_sales_bybranch", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "branch_id"
    t.string  "brand",       limit: 100
    t.integer "total"
    t.integer "sales_month"
    t.integer "sales_year"
  end

  create_table "monthly_salesmen_achievment_bybrand", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "sales_id"
    t.integer "sales_month"
    t.bigint  "sales_year"
    t.string  "sales_brand", limit: 50
    t.bigint  "sales_total"
  end

  create_table "monthly_targets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "cabang_id"
    t.string   "kode_customer",     limit: 200
    t.string   "customer",          limit: 150
    t.string   "divisi"
    t.string   "merk_id"
    t.string   "nik_bm",            limit: 50
    t.string   "bm",                limit: 200
    t.string   "nik_asm",           limit: 50
    t.string   "asm",               limit: 200
    t.string   "nik_spv",           limit: 50
    t.string   "spv",               limit: 200
    t.string   "nik_sales",         limit: 50
    t.string   "sales"
    t.string   "nik_sales_counter", limit: 50
    t.string   "sales_counter"
    t.string   "target_year",       limit: 20
    t.integer  "target_month"
    t.decimal  "total",                         precision: 10
    t.bigint   "january"
    t.bigint   "february"
    t.bigint   "march"
    t.bigint   "april"
    t.bigint   "may"
    t.bigint   "june"
    t.bigint   "july"
    t.bigint   "august"
    t.bigint   "september"
    t.bigint   "october"
    t.bigint   "november"
    t.bigint   "december"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["cabang_id"], name: "index_monthly_targets_on_cabang_id", using: :btree
    t.index ["merk_id"], name: "index_monthly_targets_on_brand_id", using: :btree
  end

  create_table "months", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.decimal "january",           precision: 10
    t.decimal "february",          precision: 10
    t.decimal "march",             precision: 10
    t.decimal "april",             precision: 10
    t.decimal "may",               precision: 10
    t.decimal "june",              precision: 10
    t.decimal "july",              precision: 10
    t.decimal "august",            precision: 10
    t.decimal "september",         precision: 10
    t.decimal "october",           precision: 10
    t.decimal "november",          precision: 10
    t.decimal "december",          precision: 10
    t.bigint  "monthly_target_id"
  end

  create_table "numbers", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "number"
  end

  create_table "numbers_small", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "number"
  end

  create_table "peddlers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "pdbp"
    t.integer  "pdwk"
    t.integer  "pdfs"
    t.integer  "pdouso"
    t.integer  "pdreal"
    t.integer  "pdbuffer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "position_incentives", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "position", limit: 10
  end

  create_table "price_list_status_histories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "price_list_id"
    t.string   "item_status"
    t.float    "harga",         limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "diskon1",                  default: 0
    t.integer  "diskon2",                  default: 0
    t.integer  "diskon3",                  default: 0
    t.integer  "diskon4",                  default: 0
    t.integer  "diskon5",                  default: 0
  end

  create_table "price_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "cabang_id"
    t.string   "kode_barang"
    t.string   "nama"
    t.integer  "brand_id"
    t.string   "jenis"
    t.string   "produk"
    t.string   "kain"
    t.string   "panjang"
    t.string   "lebar"
    t.decimal  "harga",                          precision: 10
    t.integer  "discount_1"
    t.integer  "discount_2"
    t.integer  "discount_3"
    t.integer  "discount_4"
    t.decimal  "upgrade",                        precision: 10
    t.decimal  "prev_cashback",                  precision: 10, default: 0
    t.decimal  "cashback",                       precision: 10, default: 0
    t.decimal  "special_price",                  precision: 10
    t.integer  "regional_id"
    t.boolean  "additional_program",                            default: false
    t.integer  "additional_diskon",                             default: 0
    t.datetime "program_starting_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "from_period"
    t.date     "to_period"
    t.string   "image"
    t.string   "image_filename"
    t.boolean  "active",                                        default: false
    t.string   "keterangan"
    t.string   "status"
    t.float    "harga_1",             limit: 24
    t.float    "harga_2",             limit: 24
    t.float    "harga_3",             limit: 24
    t.float    "harga_4",             limit: 24
    t.float    "harga_5",             limit: 24
  end

  create_table "provinces", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quantity_orders", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "cabang_id"
    t.datetime "tanggal"
    t.string   "no_so",       limit: 50
    t.string   "kode_barang", limit: 50
    t.bigint   "qty_order"
  end

  create_table "range_incentives", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "start_at"
    t.integer "end_at"
  end

  create_table "rate_incentive_products", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "start"
    t.integer "end"
    t.integer "product_id"
    t.integer "position_incentive_id"
    t.decimal "target_value",          precision: 10
  end

  create_table "recap_orders", id: :bigint, default: nil, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint   "so_number"
    t.datetime "order_date"
    t.integer  "order_week"
    t.integer  "order_year"
    t.string   "customer"
    t.integer  "branch_id"
    t.string   "item_number",       limit: 50
    t.string   "description"
    t.integer  "brand_id"
    t.string   "product",           limit: 5
    t.string   "artikel",           limit: 100
    t.integer  "quantity_ordered"
    t.datetime "request_date"
    t.datetime "promised_delivery"
    t.integer  "variance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipients", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string  "nama",        limit: 50
    t.string  "email",       limit: 100
    t.string  "mailing_for", limit: 50
    t.boolean "cc",                      default: false
  end

  create_table "regional_branches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "regional_id"
    t.integer  "cabang_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brand_id"
  end

  create_table "regionals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "nama"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brand_id"
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "name"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end

  create_table "sales", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "cabang_id"
    t.string   "nosj",                limit: 50
    t.datetime "tanggalsj"
    t.datetime "tanggalfaktur"
    t.string   "nofaktur",            limit: 50
    t.string   "noso",                limit: 50
    t.string   "customer",            limit: 200
    t.string   "alamatkirim"
    t.string   "salesman",            limit: 50
    t.string   "kodebrg",             limit: 50
    t.string   "namabrg"
    t.string   "jenisbrgdisc",        limit: 50
    t.string   "kodejenis",           limit: 5
    t.string   "jenisbrg",            limit: 50
    t.string   "kodeartikel",         limit: 8
    t.string   "namaartikel"
    t.string   "kodekain",            limit: 10
    t.string   "namakain"
    t.string   "panjang",             limit: 5
    t.string   "lebar",               limit: 5
    t.integer  "jumlah"
    t.string   "satuan",              limit: 5
    t.decimal  "hargasatuan",                     precision: 19, scale: 4
    t.decimal  "hargabruto",                      precision: 19, scale: 4
    t.float    "diskon1",             limit: 24
    t.float    "diskon2",             limit: 24
    t.float    "diskon3",             limit: 24
    t.float    "diskon4",             limit: 24
    t.float    "diskon5",             limit: 24
    t.decimal  "diskonsum",                       precision: 19, scale: 4
    t.decimal  "diskonrp",                        precision: 19, scale: 4
    t.decimal  "harganetto1",                     precision: 19, scale: 4
    t.decimal  "harganetto2",                     precision: 19, scale: 4
    t.decimal  "totalnetto1",                     precision: 19, scale: 4
    t.decimal  "totalnetto2",                     precision: 19, scale: 4
    t.decimal  "totalnettofaktur",                precision: 19, scale: 4
    t.decimal  "totalnettofakturLA",              precision: 19, scale: 4
    t.decimal  "totalnettofakturOK",              precision: 19, scale: 4
    t.decimal  "totalnettofakturOK2",             precision: 19, scale: 4
    t.string   "bonus",               limit: 10
    t.datetime "tanggalkirim"
    t.string   "statusbayar",         limit: 4
    t.datetime "tanggaljatuhtempo"
    t.integer  "lamabayar"
    t.string   "tipebarang",          limit: 2
    t.string   "kodesales",           limit: 10
    t.string   "kodecust",            limit: 20
    t.string   "kodepameran",         limit: 20
    t.string   "pameran"
    t.datetime "tanggalpameran1"
    t.datetime "tanggalpameran2"
    t.string   "idtrans",             limit: 20
    t.string   "nopo",                limit: 50
    t.decimal  "nupgrade",                        precision: 19, scale: 4
    t.decimal  "nettoupgrade",                    precision: 19, scale: 4
    t.string   "ketppb"
    t.string   "namabrand",           limit: 100
    t.datetime "tanggalinput"
    t.string   "kota",                limit: 50
    t.index ["cabang_id", "nosj", "tanggalsj", "tanggalfaktur", "nofaktur", "noso", "customer", "kodebrg", "jumlah"], name: "cabang_id_2", unique: true, using: :btree
    t.index ["cabang_id", "tanggalsj", "customer", "kodebrg", "nosj", "kodejenis", "kodeartikel"], name: "cabang_kodebrg_tanggal_customer", using: :btree
    t.index ["cabang_id"], name: "cabang_id", using: :btree
    t.index ["customer"], name: "customer", using: :btree
    t.index ["harganetto2"], name: "harganetto2", using: :btree
    t.index ["jenisbrgdisc"], name: "jenisbrgdisc", using: :btree
    t.index ["jumlah"], name: "jumlah", using: :btree
    t.index ["kodeartikel"], name: "kodeartikel", using: :btree
    t.index ["kodebrg"], name: "kodebrg", using: :btree
    t.index ["kodejenis"], name: "kodejenis", using: :btree
    t.index ["namabrg"], name: "namabrg", using: :btree
    t.index ["nofaktur"], name: "nofaktur", using: :btree
    t.index ["nosj"], name: "nosj", using: :btree
    t.index ["noso"], name: "noso", using: :btree
    t.index ["tanggalsj"], name: "tanggalsj", using: :btree
    t.index ["totalnetto2"], name: "totalnetto2", using: :btree
  end

  create_table "sales_articles", id: :bigint, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1" do |t|
    t.integer "bulan"
    t.string  "tahun",        limit: 10
    t.integer "cabang_id"
    t.string  "merk",         limit: 100
    t.string  "kode_artikel", limit: 100
    t.string  "artikel",      limit: 100
    t.string  "kode_produk",  limit: 100
    t.string  "produk",       limit: 100
    t.string  "kain",         limit: 100
    t.string  "ukuran",       limit: 1
    t.string  "panjang",      limit: 10
    t.string  "lebar",        limit: 10
    t.string  "customer",     limit: 200
    t.string  "sales",        limit: 100
    t.bigint  "qty"
    t.decimal "val",                      precision: 10
  end

  create_table "sales_brands", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "bulan"
    t.string  "tahun",          limit: 10
    t.integer "cabang_id"
    t.string  "merk",           limit: 100
    t.string  "artikel",        limit: 100
    t.string  "produk",         limit: 100
    t.string  "kain",           limit: 100
    t.string  "ukuran",         limit: 1
    t.string  "panjang",        limit: 10
    t.string  "lebar",          limit: 10
    t.string  "customer",       limit: 200
    t.string  "group_customer", limit: 100
    t.string  "sales",          limit: 100
    t.bigint  "qty"
    t.decimal "val",                        precision: 30
  end

  create_table "sales_customer_by_brand_years", id: :bigint, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1" do |t|
    t.string  "tahun",          limit: 10
    t.integer "cabang_id"
    t.string  "merk",           limit: 100
    t.string  "kode_artikel",   limit: 100
    t.string  "artikel",        limit: 100
    t.string  "kode_produk",    limit: 100
    t.string  "produk",         limit: 100
    t.string  "kain",           limit: 100
    t.string  "ukuran",         limit: 1
    t.string  "panjang",        limit: 10
    t.string  "lebar",          limit: 10
    t.string  "kode_customer",  limit: 100
    t.string  "customer",       limit: 200
    t.string  "sales",          limit: 100
    t.bigint  "qty"
    t.decimal "val",                        precision: 10
    t.string  "series"
    t.string  "city",           limit: 100
    t.string  "area",           limit: 100
    t.string  "tipe_customer",  limit: 100
    t.string  "group_customer", limit: 100
    t.string  "plankinggroup",  limit: 100
    t.index ["merk", "kode_artikel", "artikel", "kode_produk", "produk", "kain", "series", "kode_customer", "customer"], name: "index_text", type: :fulltext
  end

  create_table "sales_customer_by_brands", id: :bigint, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1" do |t|
    t.integer "bulan"
    t.string  "tahun",          limit: 10
    t.integer "cabang_id"
    t.string  "merk",           limit: 100
    t.string  "kode_artikel",   limit: 100
    t.string  "artikel",        limit: 100
    t.string  "kode_produk",    limit: 100
    t.string  "produk",         limit: 100
    t.string  "kain",           limit: 100
    t.string  "ukuran",         limit: 1
    t.string  "panjang",        limit: 10
    t.string  "lebar",          limit: 10
    t.string  "kode_customer",  limit: 100
    t.string  "customer",       limit: 200
    t.string  "sales",          limit: 100
    t.bigint  "qty"
    t.decimal "val",                        precision: 10
    t.string  "series"
    t.string  "city",           limit: 100
    t.string  "area",           limit: 100
    t.string  "tipe_customer",  limit: 100
    t.string  "group_customer", limit: 100
    t.string  "plankinggroup",  limit: 100
    t.index ["merk", "kode_artikel", "artikel", "kode_produk", "produk", "kain", "series", "kode_customer", "customer"], name: "index_text", type: :fulltext
  end

  create_table "sales_customer_by_cities", id: :bigint, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1" do |t|
    t.integer "bulan"
    t.string  "tahun",          limit: 10
    t.integer "cabang_id"
    t.string  "merk",           limit: 100
    t.string  "kode_artikel",   limit: 100
    t.string  "artikel",        limit: 100
    t.string  "kode_produk",    limit: 100
    t.string  "produk",         limit: 100
    t.string  "kain",           limit: 100
    t.string  "ukuran",         limit: 1
    t.string  "panjang",        limit: 10
    t.string  "lebar",          limit: 10
    t.string  "customer",       limit: 200
    t.string  "sales",          limit: 100
    t.bigint  "qty"
    t.decimal "val",                        precision: 10
    t.string  "series"
    t.string  "city",           limit: 100
    t.string  "area",           limit: 100
    t.string  "tipe_customer",  limit: 100
    t.string  "group_customer", limit: 100
    t.string  "plankinggroup",  limit: 100
    t.index ["merk", "kode_artikel", "artikel", "kode_produk", "produk", "kain", "series"], name: "index_text", type: :fulltext
  end

  create_table "sales_customers", id: :bigint, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1" do |t|
    t.integer "bulan"
    t.string  "tahun",          limit: 10
    t.integer "cabang_id"
    t.string  "merk",           limit: 100
    t.string  "kode_artikel",   limit: 100
    t.string  "artikel",        limit: 100
    t.string  "kode_produk",    limit: 100
    t.string  "produk",         limit: 100
    t.string  "kain",           limit: 100
    t.string  "ukuran",         limit: 1
    t.string  "panjang",        limit: 10
    t.string  "lebar",          limit: 10
    t.string  "customer",       limit: 200
    t.string  "sales",          limit: 100
    t.bigint  "qty"
    t.decimal "val",                        precision: 10
    t.string  "city",           limit: 100
    t.string  "area",           limit: 100
    t.string  "tipe",           limit: 100
    t.string  "group_customer", limit: 100
    t.string  "plankinggroup",  limit: 100
    t.index ["merk", "customer"], name: "customer", type: :fulltext
  end

  create_table "sales_fabrics", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "bulan"
    t.string  "tahun",        limit: 10
    t.integer "cabang_id"
    t.string  "merk",         limit: 100
    t.string  "kode_artikel", limit: 100
    t.string  "artikel",      limit: 100
    t.string  "kode_produk",  limit: 100
    t.string  "produk",       limit: 100
    t.string  "kain",         limit: 100
    t.string  "ukuran",       limit: 1
    t.string  "panjang",      limit: 10
    t.string  "lebar",        limit: 10
    t.string  "customer",     limit: 200
    t.string  "sales",        limit: 100
    t.bigint  "qty"
    t.decimal "val",                      precision: 10
  end

  create_table "sales_productivities", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "salesmen_id"
    t.integer  "branch_id"
    t.integer  "brand_id"
    t.integer  "npvnc",       default: 0
    t.integer  "nvc",         default: 0
    t.integer  "ncdv",        default: 0
    t.integer  "ncc",         default: 0
    t.integer  "ncdc",        default: 0
    t.integer  "tjp",         default: 0
    t.integer  "apt",         default: 0
    t.integer  "province_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_productivity_reports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "salesmen_id"
    t.integer  "branch_id"
    t.integer  "brand_id"
    t.integer  "month"
    t.integer  "year"
    t.float    "average_visit_day",  limit: 24
    t.float    "success_rate_visit", limit: 24
    t.float    "average_order_deal", limit: 24, default: 0.0
    t.float    "average_call_day",   limit: 24, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_products", id: :bigint, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1" do |t|
    t.integer "bulan"
    t.string  "tahun",        limit: 10
    t.integer "cabang_id"
    t.string  "merk",         limit: 100
    t.string  "kode_artikel", limit: 100
    t.string  "artikel",      limit: 100
    t.string  "kode_produk",  limit: 100
    t.string  "produk",       limit: 100
    t.string  "kain",         limit: 100
    t.string  "ukuran",       limit: 1
    t.string  "panjang",      limit: 10
    t.string  "lebar",        limit: 10
    t.string  "customer",     limit: 200
    t.string  "sales",        limit: 100
    t.bigint  "qty"
    t.decimal "val",                      precision: 10
    t.index ["merk", "kode_artikel", "artikel", "kode_produk", "produk", "kain", "customer", "sales"], name: "text", type: :fulltext
  end

  create_table "sales_products_jan2015", id: :bigint, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1" do |t|
    t.integer "bulan"
    t.string  "tahun",        limit: 10
    t.integer "cabang_id"
    t.string  "merk",         limit: 100
    t.string  "kode_artikel", limit: 100
    t.string  "artikel",      limit: 100
    t.string  "kode_produk",  limit: 100
    t.string  "produk",       limit: 100
    t.string  "kain",         limit: 100
    t.string  "ukuran",       limit: 1
    t.string  "panjang",      limit: 10
    t.string  "lebar",        limit: 10
    t.string  "customer",     limit: 200
    t.string  "sales",        limit: 100
    t.bigint  "qty"
    t.decimal "val",                      precision: 10
    t.index ["merk", "kode_artikel", "artikel", "kode_produk", "produk", "kain", "customer", "sales"], name: "text", type: :fulltext
  end

  create_table "sales_salesmen", id: :bigint, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1" do |t|
    t.integer "bulan"
    t.string  "tahun",       limit: 10
    t.integer "cabang_id"
    t.string  "merk",        limit: 100
    t.string  "artikel",     limit: 100
    t.string  "kode_produk", limit: 100
    t.string  "produk",      limit: 100
    t.string  "kain",        limit: 100
    t.string  "ukuran",      limit: 1
    t.string  "panjang",     limit: 10
    t.string  "lebar",       limit: 10
    t.string  "customer",    limit: 200
    t.string  "sales",       limit: 100
    t.bigint  "qty"
    t.decimal "val",                     precision: 10
    t.index ["merk", "artikel", "kode_produk", "produk", "kain", "customer", "sales"], name: "text", type: :fulltext
  end

  create_table "sales_sizes", id: :bigint, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1" do |t|
    t.integer "tanggal"
    t.integer "bulan"
    t.string  "tahun",          limit: 10
    t.integer "cabang_id"
    t.string  "merk",           limit: 100
    t.string  "kode_artikel",   limit: 100
    t.string  "artikel",        limit: 100
    t.string  "kode_produk",    limit: 100
    t.string  "produk",         limit: 100
    t.string  "kain",           limit: 100
    t.string  "ukuran",         limit: 1
    t.string  "panjang",        limit: 10
    t.string  "lebar",          limit: 10
    t.string  "customer",       limit: 200
    t.string  "sales",          limit: 100
    t.bigint  "qty"
    t.decimal "val",                        precision: 10
    t.string  "series"
    t.string  "city",           limit: 100
    t.string  "area",           limit: 100
    t.string  "tipe_customer",  limit: 100
    t.string  "group_customer", limit: 100
    t.string  "plankinggroup",  limit: 100
    t.index ["merk", "kode_artikel", "artikel", "kode_produk", "produk", "kain", "series"], name: "index_text", type: :fulltext
  end

  create_table "sales_target_category_product", primary_key: ["id", "range1"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "id",                 null: false
    t.string  "range1", limit: 100, null: false, comment: "60-80"
    t.string  "range2", limit: 100,              comment: "81-90"
    t.string  "range3", limit: 100,              comment: "91-100"
    t.string  "range4", limit: 100,              comment: "101-122"
    t.index ["id"], name: "id", unique: true, using: :btree
  end

  create_table "salesmen", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string  "nama",      limit: 50
    t.string  "nik",       limit: 30
    t.string  "area"
    t.integer "branch_id"
    t.integer "brand_id"
    t.index ["nama"], name: "nama", unique: true, using: :btree
  end

  create_table "store_maps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text     "address",    limit: 65535
    t.string   "city"
    t.float    "latitude",   limit: 24
    t.float    "longitude",  limit: 24
    t.boolean  "gmaps"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "target_clasic", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "cabang", limit: 35
    t.integer "bulan"
    t.integer "tahun"
    t.string  "brand",  limit: 15
    t.float   "jumlah", limit: 24
    t.float   "JTAHUN", limit: 24
  end

  create_table "target_elite", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "cabang", limit: 35
    t.integer "bulan"
    t.integer "tahun"
    t.string  "brand",  limit: 15
    t.float   "jumlah", limit: 24
    t.float   "JTAHUN", limit: 24
  end

  create_table "target_product_incentives", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "product_code"
    t.string   "product_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tbbjbarang", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "KodeBrg",        limit: 25,                           null: false
    t.string  "Nama",           limit: 200
    t.string  "Alias",          limit: 100
    t.string  "IdGrup",         limit: 10
    t.string  "Keterangan",     limit: 50
    t.binary  "Aktif",          limit: 1
    t.float   "StockMin",       limit: 24
    t.float   "StockMax",       limit: 24
    t.string  "IdSatuan",       limit: 10
    t.string  "IdSatuanBeli",   limit: 10
    t.float   "Kelipatan",      limit: 53
    t.string  "IdGudang",       limit: 10
    t.string  "IdSupp",         limit: 10
    t.float   "LeadTime",       limit: 24
    t.string  "IdJenis",        limit: 10
    t.float   "Panjang",        limit: 24
    t.float   "Lebar",          limit: 24
    t.string  "IdMerk",         limit: 10
    t.string  "Kain",           limit: 10
    t.string  "Ukuran",         limit: 20
    t.decimal "HargaBrg",                   precision: 19, scale: 4
    t.string  "idjenisbrgdisc", limit: 10
    t.index ["KodeBrg"], name: "KodeBrg", using: :btree
  end

  create_table "tbbjkodeartikel", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "KodeBrand",      limit: 2
    t.string  "KodeCollection", limit: 6,   null: false
    t.string  "Produk",         limit: 200, null: false
    t.string  "KodeProduk",     limit: 2,   null: false
    t.string  "Status",         limit: 5
    t.string  "OldName",        limit: 200
    t.integer "Aktif"
    t.float   "varpoint",       limit: 24
    t.float   "divpoint",       limit: 24
  end

  create_table "tbbjkodebrand", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "KodeBrand", limit: 2,  null: false
    t.string "NamaBrand", limit: 50
    t.float  "PcntPoin",  limit: 24
    t.float  "DivPoin",   limit: 24
    t.index ["KodeBrand"], name: "kodebrand", using: :btree
    t.index ["NamaBrand"], name: "namabrand", using: :btree
  end

  create_table "tbbjkodekain", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "KodeKain",       limit: 5,  null: false
    t.string  "NamaKain",       limit: 50
    t.string  "KodeCollection", limit: 4
    t.string  "Status",         limit: 5
    t.integer "Aktif"
    t.index ["id"], name: "PK_tbBJKodeKain", unique: true, using: :btree
  end

  create_table "tbbjkodeproduk", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "KodeProduk", limit: 2,   null: false
    t.string "Namaroduk",  limit: 100
    t.index ["KodeProduk"], name: "kodeproduk", using: :btree
    t.index ["Namaroduk"], name: "nama_produk", using: :btree
  end

  create_table "tbbjkodeukuran", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "IdUkuran",   limit: 10
    t.string "Ukuran",     limit: 50
    t.float  "Panjang",    limit: 24
    t.float  "Lebar",      limit: 24
    t.string "KodeProduk", limit: 2
  end

  create_table "tbbjmerk", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "IdMerk",    limit: 50,              null: false
    t.string "Merk",      limit: 50, default: "", null: false
    t.string "jde_brand", limit: 50
    t.index ["IdMerk"], name: "id_merk", using: :btree
    t.index ["Merk"], name: "merk", using: :btree
  end

  create_table "tbcabbarang", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string  "kodebarang",                                         null: false
    t.string  "nama"
    t.string  "alias"
    t.string  "idgrup"
    t.string  "keterangan"
    t.binary  "aktif",          limit: 1,                           null: false
    t.float   "stockmin",       limit: 24
    t.float   "stockmax",       limit: 24
    t.string  "idsatuan"
    t.string  "idsatuanbeli"
    t.float   "kelipatan",      limit: 24
    t.string  "idgudang"
    t.string  "idsupp"
    t.float   "leadtime",       limit: 24
    t.string  "idjenis"
    t.float   "panjang",        limit: 24
    t.float   "lebar",          limit: 24
    t.string  "idmerk"
    t.string  "kain"
    t.string  "ukuran"
    t.float   "hargabrg",       limit: 24
    t.string  "idjenisbrgdisc"
    t.string  "idcabang",       limit: 20,                          null: false
    t.decimal "upgradesize",               precision: 19, scale: 4
  end

  create_table "tbcabso", primary_key: "NoSO", id: :string, limit: 50, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "NoPO",         limit: 50,  null: false
    t.integer  "cabang_id",                null: false
    t.string   "AsalSO",       limit: 25,  null: false
    t.string   "KodeCustomer", limit: 10,  null: false
    t.string   "KodePameran",  limit: 20,  null: false
    t.datetime "TglSO",                    null: false
    t.datetime "TglDelivery"
    t.string   "KodeSales",    limit: 10,  null: false
    t.string   "AlamatKirim",  limit: 200, null: false
    t.string   "StatusSO",     limit: 4,   null: false
    t.string   "KeteranganSO",             null: false
    t.float    "JmlDP",        limit: 24,  null: false
    t.integer  "JmlHrKredit",              null: false
    t.string   "StatusBayar",  limit: 1,   null: false
    t.string   "JnsKartu",     limit: 50,  null: false
    t.string   "NoKartu",      limit: 30,  null: false
    t.string   "AtasNama",     limit: 30,  null: false
    t.string   "NoMerchant",   limit: 50,  null: false
    t.string   "PPN",          limit: 1,   null: false
    t.float    "JmlSumBruto",  limit: 24,  null: false
    t.float    "JmlSumDiskon", limit: 24,  null: false
    t.float    "JmlSumPPn",    limit: 24,  null: false
    t.float    "JmlSumNetto",  limit: 24,  null: false
    t.string   "UserInput",    limit: 20
    t.string   "WaktuInput",   limit: 50
    t.string   "NoPOGabungan"
    t.string   "SPG",          limit: 50
    t.string   "NonPP",        limit: 1
    t.string   "nopbj",        limit: 50
    t.index ["AsalSO"], name: "asalso", using: :btree
    t.index ["NoPO"], name: "nopo", using: :btree
    t.index ["NoSO"], name: "noso", using: :btree
    t.index ["StatusSO"], name: "status", using: :btree
    t.index ["TglSO"], name: "tanggal", using: :btree
    t.index ["cabang_id"], name: "cabang", using: :btree
  end

  create_table "tbcabsodetail", force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.string  "NoSO",        limit: 50, null: false
    t.string  "KodeBrg",     limit: 25, null: false
    t.integer "QtyOrder",               null: false
    t.integer "QtyOrdering"
    t.integer "FStock",                 null: false
    t.integer "RStock",                 null: false
    t.integer "BkPPB",                  null: false
    t.integer "PPB"
    t.integer "PBJ"
    t.string  "StatusSO",    limit: 2
    t.string  "Satuan",      limit: 5,  null: false
    t.float   "PriceList",   limit: 24
    t.float   "PriceBruto",  limit: 24
    t.float   "Disc1",       limit: 24
    t.float   "Disc2",       limit: 24
    t.float   "PriceNetto",  limit: 24
    t.string  "Bonus",       limit: 10, null: false
    t.string  "NoPBJ",       limit: 50
    t.string  "Tambahan",    limit: 10
    t.string  "Keterangan"
    t.string  "idPemutihan", limit: 30
    t.index ["KodeBrg"], name: "kode", using: :btree
    t.index ["NoSO"], name: "NoSO", using: :btree
  end

  create_table "tbidcabang", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "IdCabang", limit: 3,   null: false
    t.string "Cabang",   limit: 100
    t.string "Alamat1",  limit: 200
    t.string "Alamat2",  limit: 200
    t.string "Alias",    limit: 7
    t.string "jde_id",   limit: 7
    t.index ["IdCabang"], name: "PK_tbIdCabang", unique: true, using: :btree
  end

  create_table "tbjenisbrgdisc", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "idjenisbrgdisc", limit: 10, null: false
    t.string "nmjenisbrgdisc", limit: 50
  end

  create_table "tblaporancabang", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "cabang_id"
    t.string   "nosj",             limit: 50
    t.date     "tanggal"
    t.date     "tanggalsj"
    t.string   "nofaktur",         limit: 50
    t.string   "noso",             limit: 50
    t.string   "kode_customer",    limit: 50
    t.string   "customer",         limit: 200
    t.string   "alamatkirim"
    t.string   "salesman",         limit: 50
    t.string   "kodebrg",          limit: 50
    t.string   "namabrg"
    t.string   "jenisbrgdisc",     limit: 50
    t.string   "kodejenis",        limit: 5
    t.string   "jenisbrg",         limit: 50
    t.string   "kodeartikel",      limit: 8
    t.string   "namaartikel"
    t.string   "kodekain",         limit: 10
    t.string   "namakain"
    t.string   "panjang",          limit: 5
    t.string   "lebar",            limit: 5
    t.integer  "jumlah"
    t.string   "satuan",           limit: 5
    t.decimal  "hargasatuan",                  precision: 19
    t.decimal  "hargabruto",                   precision: 19
    t.decimal  "diskon1",                      precision: 19
    t.decimal  "diskon2",                      precision: 19
    t.decimal  "diskon3",                      precision: 19
    t.decimal  "diskon4",                      precision: 19
    t.decimal  "diskon5",                      precision: 19
    t.decimal  "diskonsum",                    precision: 19
    t.decimal  "diskonrp",                     precision: 19
    t.decimal  "harganetto1",                  precision: 19
    t.decimal  "harganetto2",                  precision: 19
    t.decimal  "totalnetto1",                  precision: 19
    t.decimal  "totalnetto2",                  precision: 19
    t.decimal  "totalnettofaktur",             precision: 19
    t.decimal  "cashback",                     precision: 19
    t.decimal  "nupgrade",                     precision: 19
    t.string   "ketppb"
    t.string   "kota",             limit: 50
    t.string   "Jenis_Customer",   limit: 50
    t.string   "namabrand",        limit: 50
    t.string   "bonus",            limit: 50
    t.string   "tipecust",         limit: 50
    t.string   "groupcust",        limit: 50
    t.string   "plankinggroup",    limit: 50
    t.datetime "tanggal_fetched"
    t.datetime "tanggal_upload"
    t.string   "nopo",             limit: 100
    t.integer  "lnid"
    t.index ["cabang_id", "tanggal", "customer", "kodebrg", "nosj", "kodejenis", "kodeartikel"], name: "cabang_kodebrg_tanggal_customer", using: :btree
    t.index ["cabang_id"], name: "cabang_id", using: :btree
    t.index ["customer"], name: "customer", using: :btree
    t.index ["harganetto2"], name: "harganetto2", using: :btree
    t.index ["jenisbrgdisc"], name: "jenisbrgdisc", using: :btree
    t.index ["jumlah"], name: "jumlah", using: :btree
    t.index ["kodeartikel"], name: "kodeartikel", using: :btree
    t.index ["kodebrg"], name: "kodebrg", using: :btree
    t.index ["kodejenis"], name: "kodejenis", using: :btree
    t.index ["namabrg"], name: "namabrg", using: :btree
    t.index ["nofaktur"], name: "nofaktur", using: :btree
    t.index ["nosj"], name: "nosj", using: :btree
    t.index ["noso"], name: "noso", using: :btree
    t.index ["tanggalsj"], name: "index", using: :btree
    t.index ["tanggalsj"], name: "tanggalsj", using: :btree
    t.index ["totalnetto2"], name: "totalnetto2", using: :btree
  end

  create_table "tbstockcabang", id: :bigint, force: :cascade, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8" do |t|
    t.date    "tanggal",                        null: false
    t.integer "cabang_id",                      null: false
    t.string  "kodebrg",            limit: 30,  null: false
    t.string  "namabrg",            limit: 100
    t.integer "freestock"
    t.integer "bufferstock"
    t.integer "outstandingSO"
    t.integer "outstandingPBJ"
    t.integer "realstock"
    t.integer "realstockservice"
    t.integer "realstockdowngrade"
    t.index ["tanggal", "cabang_id", "kodebrg"], name: "PK_TbStockCabang", unique: true, using: :btree
  end

  create_table "test_import", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "cabang_id"
    t.string   "nosj",             limit: 50
    t.date     "tanggal"
    t.date     "tanggalsj"
    t.string   "nofaktur",         limit: 50
    t.string   "noso",             limit: 50
    t.string   "kode_customer",    limit: 50
    t.string   "customer",         limit: 200
    t.string   "alamatkirim"
    t.string   "salesman",         limit: 50
    t.string   "kodebrg",          limit: 50
    t.string   "namabrg"
    t.string   "jenisbrgdisc",     limit: 50
    t.string   "kodejenis",        limit: 5
    t.string   "jenisbrg",         limit: 50
    t.string   "kodeartikel",      limit: 8
    t.string   "namaartikel"
    t.string   "kodekain",         limit: 10
    t.string   "namakain"
    t.string   "panjang",          limit: 5
    t.string   "lebar",            limit: 5
    t.integer  "jumlah"
    t.string   "satuan",           limit: 5
    t.decimal  "hargasatuan",                  precision: 19
    t.decimal  "hargabruto",                   precision: 19
    t.decimal  "diskon1",                      precision: 19
    t.decimal  "diskon2",                      precision: 19
    t.decimal  "diskon3",                      precision: 19
    t.decimal  "diskon4",                      precision: 19
    t.decimal  "diskon5",                      precision: 19
    t.decimal  "diskonsum",                    precision: 19
    t.decimal  "diskonrp",                     precision: 19
    t.decimal  "harganetto1",                  precision: 19
    t.decimal  "harganetto2",                  precision: 19
    t.decimal  "totalnetto1",                  precision: 19
    t.decimal  "totalnetto2",                  precision: 19
    t.decimal  "totalnettofaktur",             precision: 19
    t.decimal  "cashback",                     precision: 19
    t.decimal  "nupgrade",                     precision: 19
    t.string   "ketppb"
    t.string   "kota",             limit: 50
    t.string   "Jenis_Customer",   limit: 50
    t.string   "namabrand",        limit: 50
    t.string   "bonus",            limit: 50
    t.string   "tipecust",         limit: 50
    t.string   "groupcust",        limit: 50
    t.string   "plankinggroup",    limit: 50
    t.datetime "tanggal_fetched"
    t.datetime "tanggal_upload"
    t.index ["cabang_id", "tanggal", "customer", "kodebrg", "nosj", "kodejenis", "kodeartikel"], name: "cabang_kodebrg_tanggal_customer", using: :btree
    t.index ["cabang_id"], name: "cabang_id", using: :btree
    t.index ["customer"], name: "customer", using: :btree
    t.index ["harganetto2"], name: "harganetto2", using: :btree
    t.index ["jenisbrgdisc"], name: "jenisbrgdisc", using: :btree
    t.index ["jumlah"], name: "jumlah", using: :btree
    t.index ["kodeartikel"], name: "kodeartikel", using: :btree
    t.index ["kodebrg"], name: "kodebrg", using: :btree
    t.index ["kodejenis"], name: "kodejenis", using: :btree
    t.index ["namabrg"], name: "namabrg", using: :btree
    t.index ["nofaktur"], name: "nofaktur", using: :btree
    t.index ["nosj"], name: "nosj", using: :btree
    t.index ["noso"], name: "noso", using: :btree
    t.index ["tanggalsj"], name: "index", using: :btree
    t.index ["tanggalsj"], name: "tanggalsj", using: :btree
    t.index ["totalnetto2"], name: "totalnetto2", using: :btree
  end

  create_table "tmp", id: :bigint, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "cabang_id"
    t.string   "nosj",                limit: 50
    t.date     "tanggalsj"
    t.datetime "tanggalfaktur"
    t.string   "nofaktur",            limit: 50
    t.string   "noso",                limit: 50
    t.string   "customer",            limit: 200
    t.string   "alamatkirim"
    t.string   "salesman",            limit: 50
    t.string   "kodebrg",             limit: 50
    t.string   "namabrg"
    t.string   "jenisbrgdisc",        limit: 50
    t.string   "kodejenis",           limit: 5
    t.string   "jenisbrg",            limit: 50
    t.string   "kodeartikel",         limit: 8
    t.string   "namaartikel"
    t.string   "kodekain",            limit: 10
    t.string   "namakain"
    t.string   "panjang",             limit: 5
    t.string   "lebar",               limit: 5
    t.integer  "jumlah"
    t.string   "satuan",              limit: 5
    t.decimal  "hargasatuan",                     precision: 19
    t.decimal  "hargabruto",                      precision: 19
    t.decimal  "diskon1",                         precision: 19
    t.decimal  "diskon2",                         precision: 19
    t.decimal  "diskon3",                         precision: 19
    t.decimal  "diskon4",                         precision: 19
    t.decimal  "diskon5",                         precision: 19
    t.decimal  "diskonsum",                       precision: 19
    t.decimal  "diskonrp",                        precision: 19
    t.decimal  "harganetto1",                     precision: 19
    t.decimal  "harganetto2",                     precision: 19
    t.decimal  "totalnetto1",                     precision: 19
    t.decimal  "totalnetto2",                     precision: 19
    t.decimal  "totalnettofaktur",                precision: 19
    t.decimal  "totalnettofakturLA",              precision: 19
    t.decimal  "totalnettofakturOK",              precision: 19
    t.decimal  "totalnettofakturOK2",             precision: 19
    t.string   "bonus",               limit: 10
    t.datetime "tanggalkirim"
    t.string   "statusbayar",         limit: 4
    t.datetime "tanggaljatuhtempo"
    t.integer  "lamabayar"
    t.string   "tipebarang",          limit: 2
    t.string   "kodesales",           limit: 10
    t.string   "kodecust",            limit: 20
    t.string   "kodepameran",         limit: 20
    t.string   "pameran"
    t.datetime "tanggalpameran1"
    t.datetime "tanggalpameran2"
    t.string   "idtrans",             limit: 20
    t.string   "nopo",                limit: 50
    t.decimal  "nupgrade",                        precision: 19
    t.decimal  "nettoupgrade",                    precision: 19
    t.string   "ketppb"
    t.string   "namabrand",           limit: 100
    t.datetime "tanggalinput"
    t.string   "kota",                limit: 50
    t.index ["cabang_id", "kodebrg", "nofaktur"], name: "cabang_id_2", unique: true, using: :btree
    t.index ["cabang_id", "tanggalsj", "customer", "kodebrg", "nosj", "kodejenis", "kodeartikel"], name: "cabang_kodebrg_tanggal_customer", using: :btree
    t.index ["cabang_id"], name: "cabang_id", using: :btree
    t.index ["customer"], name: "customer", using: :btree
    t.index ["harganetto2"], name: "harganetto2", using: :btree
    t.index ["jenisbrgdisc"], name: "jenisbrgdisc", using: :btree
    t.index ["jumlah"], name: "jumlah", using: :btree
    t.index ["kodeartikel"], name: "kodeartikel", using: :btree
    t.index ["kodebrg"], name: "kodebrg", using: :btree
    t.index ["kodejenis"], name: "kodejenis", using: :btree
    t.index ["namabrg"], name: "namabrg", using: :btree
    t.index ["nofaktur"], name: "nofaktur", using: :btree
    t.index ["nosj"], name: "nosj", using: :btree
    t.index ["noso"], name: "noso", using: :btree
    t.index ["tanggalsj"], name: "tanggalsj", using: :btree
    t.index ["totalnetto2"], name: "totalnetto2", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "email",                              default: "",    null: false
    t.string   "encrypted_password",                 default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "user_brand"
    t.boolean  "approved",                           default: false, null: false
    t.integer  "branch"
    t.string   "sales_stock"
    t.string   "roles",                  limit: 100
    t.integer  "cabang"
    t.integer  "province"
    t.index ["approved"], name: "index_users_on_approved", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "users_mails", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "user_id"
    t.string   "brand"
    t.string   "category"
    t.integer  "cabang_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "schedule"
  end

  create_table "users_roles", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

  create_table "versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "item_type",                null: false
    t.integer  "item_id",                  null: false
    t.string   "event",                    null: false
    t.string   "whodunnit"
    t.text     "object",     limit: 65535
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  create_table "yearly_targets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "cabang_id"
    t.string   "target_year", limit: 4
    t.string   "brand_id",    limit: 100
    t.decimal  "total",                   precision: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["brand_id"], name: "index_yearly_targets_on_brand_id", using: :btree
    t.index ["cabang_id"], name: "index_yearly_targets_on_cabang_id", using: :btree
    t.index ["target_year"], name: "index_yearly_targets_on_target_year", using: :btree
  end

end
