# Design Spec: Customer Decrease Table & Export Clean Up

- **Date:** 2026-10-03
- **Topic:** Customer Decrease Excel & CSV Export Fix and Column Removal
- **Status:** Approved

## 1. Overview & Objectives
Di halaman `/penjualan/nasional/` untuk fitur *Customer Decrease*, hasil export ke Excel sebelumnya mengalami kegagalan/corrupt saat dibuka. Hal ini disebabkan oleh adanya karakter non-standar (panah unicode `➔`) serta tag HTML formatting (`<span>`, `<i>`) pada 3 kolom selisih (`Selisih (W4➔W3)`, `Selisih (W3➔W2)`, `Selisih (W2➔W1)`).

Tujuan dari perubahan ini:
1. Menghilangkan ketiga kolom selisih dari tabel web.
2. Memastikan hasil export ke format Excel (.xlsx) dan CSV dapat dibuka dan terbaca dengan baik tanpa error XML atau parsing issue.

## 2. Scope & Affected Files
- **View Template:** [`app/views/penjualan/template_dashboard/customer_decrease.html.erb`](file:///home/it-dev/apps/NEW_SA/app/views/penjualan/template_dashboard/customer_decrease.html.erb)
- **Controller/Brand Routes yang terpengaruh:**
  - `/penjualan/nasional/nasional_elites/customer_decrease`
  - `/penjualan/nasional/nasional_serenity/customer_decrease`
  - `/penjualan/nasional/nasional_lady/customer_decrease`
  - `/penjualan/nasional/nasional_royal/customer_decrease`
  - `/penjualan/nasional/nasional_tote/customer_decrease`
  *(Semua controller di atas me-render template `customer_decrease.html.erb` yang sama)*

## 3. Detailed Specifications

### 3.1 Table Header (`<thead>`)
Struktur header tabel disederhanakan menjadi 8 kolom:
1. `Branch`
2. `Brand`
3. `Customer`
4. `City`
5. `Week <%= 4.weeks.ago.to_date.cweek %>`
6. `Week <%= 3.weeks.ago.to_date.cweek %>`
7. `Week <%= 2.weeks.ago.to_date.cweek %>`
8. `Week <%= 1.weeks.ago.to_date.cweek %>`

*Kolom yang dihapus:*
- `Selisih (W4➔W3)`
- `Selisih (W3➔W2)`
- `Selisih (W2➔W1)`

### 3.2 Table Body (`<tbody>`)
- Menghapus blok logic kalkulasi Ruby per baris:
  ```ruby
  diff_34 = dp.w3.to_f - dp.w4.to_f
  diff_23 = dp.w2.to_f - dp.w3.to_f
  diff_12 = dp.w1.to_f - dp.w2.to_f
  ```
- Menghapus 3 elemen `<td>` yang merender `diff_34`, `diff_23`, dan `diff_12` beserta tag styling `<span class="text-danger">`, `<i class="fa fa-caret-down">`, dll.
- Baris tabel hanya merender 8 kolom:
  - `<td><%= dp.cabang.to_s.gsub('Cabang', '') %></td>`
  - `<td><%= dp.jenisbrgdisc %></td>`
  - `<td><%= dp.customer %></td>`
  - `<td><%= dp.kota %></td>`
  - `<td><%= currency(dp.w4) %></td>`
  - `<td><%= currency(dp.w3) %></td>`
  - `<td><%= currency(dp.w2) %></td>`
  - `<td><%= currency(dp.w1) %></td>`

### 3.3 Export Behavior (DataTables HTML5 Buttons)
- DataTables button setup untuk `#table-revenue-products` mengekspor isi tabel langsung ke Excel (.xlsx) dan CSV.
- Dengan dihilangkannya tag HTML dan karakter khusus dari kolom selisih, string XML pada file Excel yang dihasilkan oleh JSZip menjadi valid dan dapat dibuka tanpa corrupt warning.

## 4. Verification & Testing
1. **Sintaks & Integritas View:**
   - Memastikan simetri jumlah kolom `<th>` (8 kolom) dan `<td>` (8 kolom).
   - Memastikan tidak ada sisa variabel `diff_*` yang tidak terpakai atau memicu error runtime.
2. **Export Testing:**
   - Verifikasi data yang diexport ke Excel dan CSV berisi 8 kolom yang sesuai dan file dapat dibuka secara normal.
