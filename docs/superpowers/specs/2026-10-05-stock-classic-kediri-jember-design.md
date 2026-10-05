# Design Spec: Submenu Classic (Manufacture & Normal) untuk Kediri dan Jember

## 1. Overview
Menambahkan sub-menu pada brand **Classic** di menu Stock untuk cabang **Kediri** dan **Jember** agar konsisten dengan struktur yang diterapkan di cabang Surabaya. Menu Classic akan memiliki dua sub-kategori: **Manufacture** dan **Normal**.

## 2. Changes & Components

### 2.1 Sidebar Partial Kediri
- **File:** `app/views/layouts/partials/_stock_kediri.html.erb`
- **Tindakan:** Mengubah link tunggal Classic menjadi menu dropdown collapsible (`#stock-kediri-classic`).
- **Sub-menu Items:**
  1. **Manufacture:**
     - Target URL: `/stock/kediri/classic/normal`
     - Icon: `icon-wrench`
     - Active Condition: `controller?('stock/kediri') && params[:brand] == 'classic'`
  2. **Normal:**
     - Target URL: `/stock/kediri/stock_elite/stock_classic`
     - Icon: `icon-check`
     - Active Condition: `controller?('stock/kediri/stock_elite') && action?('stock_classic')`
- **Parent Li Active Condition:** `(controller?('stock/kediri') && params[:brand] == 'classic') || (controller?('stock/kediri/stock_elite') && action?('stock_classic'))`

### 2.2 Sidebar Partial Jember
- **File:** `app/views/layouts/partials/_stock_jember.html.erb`
- **Tindakan:** Mengubah link tunggal Classic menjadi menu dropdown collapsible (`#stock-jember-classic`).
- **Sub-menu Items:**
  1. **Manufacture:**
     - Target URL: `/stock/jember/classic/normal`
     - Icon: `icon-wrench`
     - Active Condition: `controller?('stock/jember') && params[:brand] == 'classic'`
  2. **Normal:**
     - Target URL: `/stock/jember/stock_elite/stock_classic`
     - Icon: `icon-check`
     - Active Condition: `controller?('stock/jember/stock_elite') && action?('stock_classic')`
- **Parent Li Active Condition:** `(controller?('stock/jember') && params[:brand] == 'classic') || (controller?('stock/jember/stock_elite') && action?('stock_classic'))`

## 3. Data Flow & Routing Details

| Cabang | Sub-Menu | Route | Controller & Action | Branch Plant | Brand Code |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Kediri | Manufacture | `/stock/kediri/classic/normal` | `Stock::KediriController#show` | `1206104` | `C` |
| Kediri | Normal | `/stock/kediri/stock_elite/stock_classic` | `Stock::Kediri::StockEliteController#stock_classic` | `1806104` | `C` |
| Jember | Manufacture | `/stock/jember/classic/normal` | `Stock::JemberController#show` | `1206106` | `C` |
| Jember | Normal | `/stock/jember/stock_elite/stock_classic` | `Stock::Jember::StockEliteController#stock_classic` | `1806106` | `C` |

## 4. Testing & Verification
1. Verifikasi sintaks view ERB (`bin/rails runner "ActionView::Template.new(...)"` atau syntax check).
2. Verifikasi respon endpoint:
   - Request GET ke `/stock/kediri/classic/normal` menghasilkan HTTP 200 / template render yang benar.
   - Request GET ke `/stock/kediri/stock_elite/stock_classic` menghasilkan HTTP 200 / template render yang benar.
   - Request GET ke `/stock/jember/classic/normal` menghasilkan HTTP 200 / template render yang benar.
   - Request GET ke `/stock/jember/stock_elite/stock_classic` menghasilkan HTTP 200 / template render yang benar.
3. Verifikasi class `active` dan `collapse` pada sidebar HTML.
