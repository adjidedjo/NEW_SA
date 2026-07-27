# Design Spec: Weekly Change Columns for Customer Decrease Page

**Date:** 2026-07-27  
**Status:** Approved  
**Target Path:** `app/views/penjualan/template_dashboard/customer_decrease.html.erb`

---

## 1. Overview & Feature Goal

Halaman Customer Decrease (`/penjualan/nasional/*/customer_decrease`) menampilkan tabel transaksi penjualan 4 minggu terakhir (`w4`, `w3`, `w2`, `w1`).

Fitur ini menambahkan **kolom selisih/perubahan omset antar minggu** (W4➔W3, W3➔W2, W2➔W1) beserta indikator visual warna (merah untuk penurunan, hijau untuk kenaikan) agar pengguna dapat melihat perubahan order per minggu secara langsung.

---

## 2. Proposed Changes

### 2.1 View Template: `app/views/penjualan/template_dashboard/customer_decrease.html.erb`

1. **Header Tabel**:
   - `Branch`
   - `Brand`
   - `Customer`
   - `City`
   - `Week 4` (`w4`)
   - `Week 3` (`w3`)
   - `Selisih (W4➔W3)`
   - `Week 2` (`w2`)
   - `Selisih (W3➔W2)`
   - `Week 1` (`w1`)
   - `Selisih (W2➔W1)`

2. **Perhitungan Selisih**:
   - `diff_34 = dp.w3.to_f - dp.w4.to_f`
   - `diff_23 = dp.w2.to_f - dp.w3.to_f`
   - `diff_12 = dp.w1.to_f - dp.w2.to_f`

3. **Styling & Indikator Visual**:
   - **Jika `diff < 0`**: Merah `<span class="text-danger"><i class="fa fa-caret-down"></i> <%= currency(diff) %></span>`
   - **Jika `diff > 0`**: Hijau `<span class="text-success"><i class="fa fa-caret-up"></i> <%= currency(diff) %></span>`
   - **Jika `diff == 0`**: Minimalis `-`

---

## 3. Verification Plan

1. Kompilasi ERB `customer_decrease.html.erb` dengan `rails runner`.
2. Pastikan perhitungan selisih untuk `W4->W3`, `W3->W2`, `W2->W1` berjalan dengan benar dan bebas error.
