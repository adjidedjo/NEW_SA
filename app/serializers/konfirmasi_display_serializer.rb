class KonfirmasiDisplaySerializer < ActiveModel::Serializer
  attributes :id, :kode_toko, :toko, :kode_sales, :salesman, :brand, :tanggal, :image
end
