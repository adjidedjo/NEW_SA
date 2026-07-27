# Design Spec: Fix Empty Data and ERB Syntax Error on Customer Decrease Page

**Date:** 2026-07-27  
**Status:** Approved  
**Target Path:** `/penjualan/nasional/nasional_tote/customer_decrease`

---

## 1. Overview & Problem Statement

Halaman `/penjualan/nasional/nasional_tote/customer_decrease` menampilkan tabel data "CUSTOMER DECREASE" khusus tipe customer RETAIL (`tipecust = 'RETAIL'`).

### Issues & Root Cause
1. **Data RETAIL Kosong**:
   Disebabkan oleh klausa `AND area_id IS NOT NULL` pada `Penjualan::Customer.customer_decrease(brand)`. Transaksi RETAIL TOTE pada database memiliki `area_id = NULL`.
2. **SyntaxError di Production ERB Parser**:
   Pemanggilan `<%= dp.cabang&.gsub('Cabang', '') %>` menggunakan operator `&.` di dalam tag ERB memicu `SyntaxError: unexpected '.'` pada ERB parser environment production.

---

## 2. Proposed Changes

### 2.1 Model: `app/models/penjualan/customer.rb`

Modifikasi method `self.customer_decrease(brand)`:
- Hapus filter `AND area_id IS NOT NULL` dari subquery.
- Gunakan `IFNULL(cb.Cabang, 'PUSAT/RETAIL') AS cabang` sebagai fallback nama cabang.

### 2.2 View Template: `app/views/penjualan/template_dashboard/customer_decrease.html.erb`

Ubah pemrosesan nama cabang pada baris 33:
- Ganti `<%= dp.cabang&.gsub('Cabang', '') %>` dengan `<%= dp.cabang.to_s.gsub('Cabang', '') %>`.
- Penggunaan `.to_s` menjamin 100% kompatibilitas dengan parser ERB di semua versi Ruby/Rails di production tanpa menyebabkan `SyntaxError` maupun `NoMethodError`.

---

## 3. Verification Plan

1. Pastikan ERB template `customer_decrease.html.erb` terkompilasi dengan bersih tanpa `SyntaxError`.
2. Jalankan verification script via `rails runner` (Ruby 2.5.8) untuk memastikan 4 customer RETAIL TOTE dapat dirender dengan cabang `"PUSAT/RETAIL"`.
