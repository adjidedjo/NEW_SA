class Stock::Img < ActiveRecord::Base
  establish_connection :pos
  self.table_name = "exhibition_stock_items"
  
  def self.stock_pos
    find_by_sql("SELECT a.channel_customer_id, b.nama, SUM(a.jumlah) AS jumlah, a.kode_barang, a.nama as nama_barang
    FROM exhibition_stock_items a INNER JOIN channel_customers b ON a.channel_customer_id = b.id 
    WHERE a.jumlah >= 1 AND a.checked_in = 1 AND a.checked_out = 0 AND a.rejected = 0 
    AND a.channel_customer_id IS NOT NULL  AND b.address_number > 0 GROUP BY a.channel_customer_id, a.kode_barang;")
  end
end