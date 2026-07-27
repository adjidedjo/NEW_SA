# Design Spec: Fix Empty Data in Customer Decrease Page (Strictly RETAIL)

**Date:** 2026-07-27  
**Status:** Approved  
**Target Path:** `/penjualan/nasional/nasional_tote/customer_decrease`

---

## 1. Overview & Problem Statement

Halaman `/penjualan/nasional/nasional_tote/customer_decrease` menampilkan tabel data "CUSTOMER DECREASE". Halaman ini ditujukan **khusus untuk tipe customer RETAIL** (`tipecust = 'RETAIL'`).

Saat ini data bertipe `RETAIL` untuk TOTE tampil kosong (0 baris).

### Root Cause
Di database (`dbmarketing.tblaporancabang2`), transaksi TOTE bertipe `RETAIL` dalam 4 minggu terakhir **tersedia** (4 customer: `LAVITA`, `PLAZA MEUBEL`, `PT ALPINE INDO MANDIRI`, dan `DEPO PELITA PURWOKERTO`).

Penyebab tunggal data tersebut terbuang adalah klausa **`AND area_id IS NOT NULL`** pada subquery `Penjualan::Customer.customer_decrease(brand)`. Seluruh transaksi RETAIL TOTE pada periode tersebut memiliki nilai `area_id = NULL` di database.

---

## 2. Proposed Changes

### 2.1 Model: `app/models/penjualan/customer.rb`

Modifikasi method `self.customer_decrease(brand)`:

1. **Pertahankan `tipecust = 'RETAIL'` untuk Semua Brand**:
   - Seluruh query tetap memfilter `tipecust = 'RETAIL'`.

2. **Hapus Filter `AND area_id IS NOT NULL`**:
   - Hapus klausa `AND area_id IS NOT NULL` dari subquery agar transaksi RETAIL yang tidak memiliki `area_id` (bernilai `NULL`) dapat ikut ditarik dan dihitung.

3. **Dukungan Null Cabang**:
   - Gunakan `IFNULL(cb.Cabang, 'PUSAT/RETAIL') AS cabang` untuk memberikan nama cabang fallback yang jelas bagi transaksi tanpa `area_id`.

### 2.2 View Template: `app/views/penjualan/template_dashboard/customer_decrease.html.erb`

1. Tamat pengamanan safe navigation `&.` saat memproses kolom `cabang`:
   - Gunakan `<%= dp.cabang&.gsub('Cabang', '') %>` untuk mencegah runtime error `NoMethodError` jika `cabang` bernilai `nil`.

---

## 3. Data Flow & Expected Outcome

1. Saat request masuk ke `Penjualan::Nasional::NasionalToteController#customer_decrease`:
   - `Penjualan::Customer.customer_decrease("TOTE")` dipanggil.
2. Query SQL menarik seluruh data penjualan bertipe `RETAIL` tanpa mengeliminasi data yang `area_id`-nya `NULL`.
3. Mengembalikan 4 record customer RETAIL untuk brand TOTE.
4. View template merender tabel dengan aman menggunakan cabang `'PUSAT/RETAIL'`.

---

## 4. Verification Plan

1. Jalankan script verification via `rails runner` (environment Ruby 2.5.8) untuk memastikan `Penjualan::Customer.customer_decrease('TOTE')` mengembalikan 4 customer RETAIL.
2. Pastikan query brand lain (`ELITE`, `LADY`, `ROYAL`, `SERENITY`) tidak mengalami masalah regresi.
