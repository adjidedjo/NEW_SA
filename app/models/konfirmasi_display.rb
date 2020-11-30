class KonfirmasiDisplay < ApplicationRecord
  mount_uploader :image, ImageUploader
  
  before_create :cari_toko, :cari_nama_sales
  
  validate :customer_must_be_fill, on: :create
  validate :customer_must_match, on: :create
  
  def self.get_salesman(user)
    if user.position == 'sales'
      find_by_sql("SELECT salesman, kode_sales FROM jde_salesman WHERE kode_sales = '#{user.address_number}' GROUP BY kode_sales ORDER BY kode_sales ASC")
    elsif user.position == 'admin sales'
      find_by_sql("SELECT salesman, kode_sales FROM jde_salesman WHERE area_id = '#{user.branch1}' GROUP BY kode_sales ORDER BY kode_sales ASC")
    else
      find_by_sql("SELECT salesman, kode_sales FROM jde_salesman GROUP BY kode_sales ORDER BY salesman ASC")
    end
  end
  
  def self.get_customer(user)
    if user.position == 'sales'
      find_by_sql("SELECT kode_customer, customer FROM jde_salesman WHERE kode_sales = '#{user.address_number}' GROUP BY kode_customer ORDER BY customer ASC")
    elsif user.position == 'admin sales'
      find_by_sql("SELECT kode_customer, customer FROM jde_salesman WHERE area_id = '#{user.branch1}' GROUP BY kode_customer ORDER BY customer ASC")
    else
      find_by_sql("SELECT kode_customer, customer FROM jde_salesman GROUP BY kode_customer ORDER BY customer ASC")
    end
  end
  
  private
  
  def cari_nama_sales
    self.salesman = cek_sales.first.salesman
  end
  
  def cari_toko
    self.kode_toko = cek_toko.first.kode_customer
  end
  
  def cek_toko
    Customer.find_by_sql("SELECT kode_customer FROM jde_salesman WHERE customer = '#{self.toko}'")
  end
  
  def cek_sales
    Customer.find_by_sql("SELECT TRIM(salesman) AS salesman FROM jde_salesman WHERE kode_sales = '#{self.kode_sales}' GROUP BY kode_sales")
  end
  
  def customer_must_match
    errors.add(:base, "Customer yang anda pilih tidak dalam list") if cek_toko.empty?
  end
  
  def customer_must_be_fill
    errors.add(:base, "Silahkan Isi Customer") if self.toko.empty?
  end
end
