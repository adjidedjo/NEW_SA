# Design Spec: Optimalisasi Performa Query Customer Decrease

## 1. Overview
Mengatasi bottleneck performa pada menu **Customer Decrease** (`Penjualan::Customer.customer_decrease`) yang sebelumnya memakan waktu lebih dari 60 detik (timeout / freeze) akibat correlated subquery tanpa index di tabel `tblaporancabang2` (4,9 juta baris).

## 2. Root Cause Analysis
- Pada implementasi sebelumnya di `app/models/penjualan/customer.rb`:
  ```sql
  COALESCE(
    MAX(a.area_id),
    (SELECT sub.area_id FROM dbmarketing.tblaporancabang2 sub WHERE sub.kode_customer = a.kode_customer AND sub.area_id IS NOT NULL AND sub.area_id != 0 ORDER BY sub.tanggalsj DESC LIMIT 1)
  ) AS resolved_area_id
  ```
- Subquery tersebut dieksekusi secara berulang untuk setiap baris hasil `GROUP BY` customer. Karena kolom `kode_customer` pada `tblaporancabang2` tidak memiliki index, MySQL melakukan full scan ke seluruh tabel (4,9 juta baris) untuk setiap customer.

## 3. Proposed Solution
Menghilangkan correlated subquery dan memanfaatkan agregasi langsung `MAX(a.area_id) AS resolved_area_id` dari subset data transaksi 5 minggu terakhir yang sudah difilter berdasarkan `tanggalsj`, `jenisbrgdisc`, dan `tipecust`.

### Query Baru (`Penjualan::Customer.customer_decrease`):
```ruby
def self.customer_decrease(brand)
  date = Date.today
  customer_type_condition = brand == 'TOTE' ? "tipecust IN ('RETAIL', 'ONLINE', 'MODERN', 'DIRECT')" : "tipecust = 'RETAIL'"

  find_by_sql("
    SELECT IFNULL(cb.Cabang, 'PUSAT/RETAIL') AS cabang, b.* FROM (
      SELECT 
        MAX(a.area_id) AS resolved_area_id,
        a.customer, a.kode_customer, a.jenisbrgdisc, a.kota,
        IFNULL(SUM(CASE WHEN a.week = '#{4.weeks.ago.to_date.cweek}' AND a.fiscal_year = '#{4.weeks.ago.to_date.year}' THEN a.harganetto2 END), 0) AS w4,
        IFNULL(SUM(CASE WHEN a.week = '#{3.weeks.ago.to_date.cweek}' AND a.fiscal_year = '#{3.weeks.ago.to_date.year}' THEN a.harganetto2 END), 0) AS w3,
        IFNULL(SUM(CASE WHEN a.week = '#{2.weeks.ago.to_date.cweek}' AND a.fiscal_year = '#{2.weeks.ago.to_date.year}' THEN a.harganetto2 END), 0) AS w2,
        IFNULL(SUM(CASE WHEN a.week = '#{1.weeks.ago.to_date.cweek}' AND a.fiscal_year = '#{1.weeks.ago.to_date.year}' THEN a.harganetto2 END), 0) AS w1
        FROM (
          SELECT jenisbrgdisc, area_id, customer, kode_customer, kota, harganetto2, WEEK, fiscal_year
          FROM dbmarketing.tblaporancabang2
          WHERE tanggalsj BETWEEN '#{5.weeks.ago.to_date}' AND '#{1.weeks.ago.end_of_week.to_date}' 
            AND jenisbrgdisc REGEXP '#{brand}' 
            AND #{customer_type_condition}
        ) a GROUP BY a.customer, a.jenisbrgdisc
    ) b
    LEFT JOIN dbmarketing.tbidcabang cb ON cb.id = b.resolved_area_id
    ORDER BY b.customer
  ")
end
```

## 4. Verification & Benchmarking
1. Eksekusi query untuk berbagai brand (`ELITE`, `ROYAL`, `LADY`, `SERENITY`, `TOTE`).
2. Konfirmasi waktu eksekusi berada di kisaran ~3-4 detik.
3. Konfirmasi struktur data kolom yang dihasilkan kompatibel dengan view `app/views/penjualan/template_dashboard/customer_decrease.html.erb`.
