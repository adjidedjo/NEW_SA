# Implementation Plan: Optimalisasi Query Customer Decrease

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Mengoptimalkan query `Penjualan::Customer.customer_decrease` untuk menghilangkan correlated subquery yang lambat sehingga waktu load berkurang dari > 60 detik menjadi ~3-4 detik.

**Architecture:** Memperbarui method `customer_decrease` di `app/models/penjualan/customer.rb` dengan mengganti subquery lookup area_id menjadi agregasi langsung `MAX(a.area_id) AS resolved_area_id`.

**Tech Stack:** Ruby on Rails, MySQL, ActiveRecord.

## Global Constraints
- File yang dimodifikasi: `app/models/penjualan/customer.rb`
- Method: `self.customer_decrease(brand)`
- Kolom hasil query harus tetap konsisten: `cabang`, `customer`, `kode_customer`, `jenisbrgdisc`, `kota`, `w4`, `w3`, `w2`, `w1`
- Waktu respon query harus < 5 detik untuk semua brand (`ELITE`, `ROYAL`, `LADY`, `SERENITY`, `TOTE`)

---

### Task 1: Update Query `customer_decrease` di Model `Penjualan::Customer`

**Files:**
- Modify: `app/models/penjualan/customer.rb:20-43`

**Interfaces:**
- Consumes: Parameter `brand` (string, e.g. `'ELITE'`, `'ROYAL'`, `'TOTE'`)
- Produces: ActiveRecord result set dengan kolom `cabang`, `customer`, `kode_customer`, `jenisbrgdisc`, `kota`, `w4`, `w3`, `w2`, `w1`

- [ ] **Step 1: Update method `customer_decrease` di `app/models/penjualan/customer.rb`**

Ganti baris 20-43 menjadi:
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

- [ ] **Step 2: Syntax check pada file `app/models/penjualan/customer.rb`**

Run: `ruby -c app/models/penjualan/customer.rb`
Expected: `Syntax OK`

- [ ] **Step 3: Commit perubahan**

```bash
git add app/models/penjualan/customer.rb
git commit -m "perf(penjualan): remove correlated subquery in customer_decrease for faster load"
```

---

### Task 2: Verifikasi Query & Benchmark Performa Database

**Files:**
- Test/Verify: Database query performance test script

- [ ] **Step 1: Test benchmark query MySQL untuk brand ELITE, ROYAL, TOTE**

Jalankan query test untuk memverifikasi waktu eksekusi:
```bash
mysql -h 172.16.2.74 -u root -p'Roy@l4b@d!' -e "
SELECT count(*) AS total_rows FROM (
  SELECT IFNULL(cb.Cabang, 'PUSAT/RETAIL') AS cabang, b.* FROM (
    SELECT 
      MAX(a.area_id) AS resolved_area_id,
      a.customer, a.kode_customer, a.jenisbrgdisc, a.kota,
      IFNULL(SUM(CASE WHEN a.week = '39' AND a.fiscal_year = '2026' THEN a.harganetto2 END), 0) AS w4,
      IFNULL(SUM(CASE WHEN a.week = '40' AND a.fiscal_year = '2026' THEN a.harganetto2 END), 0) AS w3,
      IFNULL(SUM(CASE WHEN a.week = '41' AND a.fiscal_year = '2026' THEN a.harganetto2 END), 0) AS w2,
      IFNULL(SUM(CASE WHEN a.week = '42' AND a.fiscal_year = '2026' THEN a.harganetto2 END), 0) AS w1
      FROM (
        SELECT jenisbrgdisc, area_id, customer, kode_customer, kota, harganetto2, WEEK, fiscal_year
        FROM dbmarketing.tblaporancabang2
        WHERE tanggalsj BETWEEN '2026-08-31' AND '2026-10-04' 
          AND jenisbrgdisc REGEXP 'ELITE' 
          AND tipecust = 'RETAIL'
      ) a GROUP BY a.customer, a.jenisbrgdisc
  ) b
  LEFT JOIN dbmarketing.tbidcabang cb ON cb.id = b.resolved_area_id
  ORDER BY b.customer
) res;
"
```
Expected: Query selesai dalam < 5 detik dengan baris data yang valid.

- [ ] **Step 2: Verifikasi view template compatibility**

Run:
```bash
erb -P -x -T '-' app/views/penjualan/template_dashboard/customer_decrease.html.erb | ruby -c
```
Expected: `Syntax OK`
