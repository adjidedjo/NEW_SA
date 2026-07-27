# Design Spec: Fix Empty Data in Customer Decrease Page for Brand TOTE

**Date:** 2026-07-27  
**Status:** Approved  
**Target Path:** `/penjualan/nasional/nasional_tote/customer_decrease`

---

## 1. Overview & Problem Statement

Halaman `/penjualan/nasional/nasional_tote/customer_decrease` menampilkan tabel data bertajuk "CUSTOMER DECREASE". Saat ini, data yang ditampilkan kosong (0 baris).

### Root Cause
1. **Hardcoded Filter `tipecust = 'RETAIL'`**:
   Method `Penjualan::Customer.customer_decrease(brand)` pada `app/models/penjualan/customer.rb` memfilter data dengan `tipecust = 'RETAIL'`. Mayoritas penjualan brand **TOTE** di database (`dbmarketing.tblaporancabang2`) tidak bertipe `RETAIL`, melainkan bertipe `ONLINE` (7,239 transaksi), `MODERN` (565 transaksi), `DIRECT` (263 transaksi), dan `INTERCO` (421 transaksi). Penjualan bertipe `RETAIL` hanya berjumlah 6 transaksi.
2. **Filter `area_id IS NOT NULL`**:
   Ke-6 transaksi `RETAIL` brand TOTE tersebut memiliki nilai `area_id = NULL`, sehingga tereliminasi oleh klausa `AND area_id IS NOT NULL`.

---

## 2. Proposed Changes

### 2.1 Model: `app/models/penjualan/customer.rb`

Modifikasi method `self.customer_decrease(brand)`:

1. **Fleksibilitas `tipecust` berdasarkan Brand**:
   - Jika `brand == 'TOTE'`, gunakan `tipecust IN ('RETAIL', 'ONLINE', 'MODERN', 'DIRECT')` (atau hilangkan restriksi `tipecust = 'RETAIL'` khusus TOTE agar mencakup semua tipe customer).
   - Untuk brand lain (`ELITE`, `LADY`, `ROYAL`, `SERENITY`), tetap pertahankan `tipecust = 'RETAIL'` agar tidak merubah perilaku existing.

2. **Dukungan Null `area_id` & Nama Cabang**:
   - Ubah `AND area_id IS NOT NULL` pada subquery agar data bertipe `ONLINE` / tanpa `area_id` spesifik tidak terbuang jika `area_id` berharga null.
   - Pada pemilihan nama cabang, gunakan `IFNULL(cb.Cabang, 'ONLINE/PUSAT') AS cabang` untuk memberikan nama fallback yang jelas.

### 2.2 View Template: `app/views/penjualan/template_dashboard/customer_decrease.html.erb`

1. Tamat pengamanan safe navigation `&.` saat memproses kolom `cabang`:
   - Ubah `<%= dp.cabang.gsub('Cabang', '') %>` menjadi `<%= dp.cabang&.gsub('Cabang', '') %>` untuk mencegah runtime error `NoMethodError` jika `cabang` bernilai `nil`.

---

## 3. Data Flow & Expected Outcome

1. Saat request masuk ke `Penjualan::Nasional::NasionalToteController#customer_decrease`:
   - `initialize_brand` mengembalikan `"TOTE"`.
   - `Penjualan::Customer.customer_decrease("TOTE")` dipanggil.
2. Query SQL menyesuaikan filter `tipecust` untuk brand `"TOTE"` sehingga menarik data penjualan bertipe `ONLINE`, `MODERN`, `DIRECT`, dan `RETAIL`.
3. Hasil query yang semula 0 baris kini mengembalikan data transaksi customer decrease brand TOTE.
4. View template merender tabel dengan nama cabang fallback jika ada transaksi tanpa `area_id`.

---

## 4. Verification Plan

1. Jalankan script verification via `rails runner` (environment Ruby 2.5.8) untuk memastikan `Penjualan::Customer.customer_decrease('TOTE')` mengembalikan jumlah baris > 0.
2. Pastikan query brand lain (`ELITE`, `LADY`, `ROYAL`, `SERENITY`) tidak mengalami regresi dan tetap mengembalikan data yang sama.
