# Implementation Plan: Submenu Classic (Manufacture & Normal) untuk Kediri dan Jember

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menambahkan sub-menu dropdown collapsible pada brand Classic di sidebar menu Stock untuk cabang Kediri dan Jember yang memuat link Manufacture dan Normal.

**Architecture:** Memperbarui file view sidebar partials `_stock_kediri.html.erb` dan `_stock_jember.html.erb` dengan komponen collapsible subnav yang mengarah ke endpoint yang sudah tersedia di backend (`Stock::KediriController` / `Stock::JemberController` untuk Manufacture dan `StockEliteController#stock_classic` untuk Normal).

**Tech Stack:** Ruby on Rails 5 / ERB, Bootstrap 3 Collapse UI.

## Global Constraints
- Sidebar dropdown ID untuk Kediri: `#stock-kediri-classic`
- Sidebar dropdown ID untuk Jember: `#stock-jember-classic`
- Submenu label teks: "Manufacture" (icon `icon-wrench`) dan "Normal" (icon `icon-check`)
- Href Manufacture Kediri: `/stock/kediri/classic/normal`
- Href Normal Kediri: `/stock/kediri/stock_elite/stock_classic`
- Href Manufacture Jember: `/stock/jember/classic/normal`
- Href Normal Jember: `/stock/jember/stock_elite/stock_classic`

---

### Task 1: Update Sidebar Partial Kediri

**Files:**
- Modify: `app/views/layouts/partials/_stock_kediri.html.erb:139-141`

**Interfaces:**
- Consumes: `controller?`, `action?`, `params[:brand]` helpers
- Produces: Collapsible Classic menu dengan item Manufacture dan Normal untuk Kediri

- [ ] **Step 1: Edit `app/views/layouts/partials/_stock_kediri.html.erb`**

Ganti bagian menu Classic (baris 139-141) dari link tunggal menjadi:
```erb
    <%# CLASSIC %>
    <li class="<%= 'active' if (controller?('stock/kediri') && params[:brand] == 'classic') || (controller?('stock/kediri/stock_elite') && action?('stock_classic')) %>">
      <a href="#stock-kediri-classic" title="Classic" data-toggle="collapse"> <em class="icon-basket-loaded"></em> <span>Classic</span> </a>
      <ul id="stock-kediri-classic" class="nav sidebar-subnav collapse">
        <li class="<%= 'active' if controller?('stock/kediri') && params[:brand] == 'classic' %>">
          <a href="/stock/kediri/classic/normal" title="Manufacture"> <em class="icon-wrench"></em> <span>Manufacture</span> </a>
        </li>
        <li class="<%= 'active' if controller?('stock/kediri/stock_elite') && action?('stock_classic') %>">
          <a href="/stock/kediri/stock_elite/stock_classic" title="Normal"> <em class="icon-check"></em> <span>Normal</span> </a>
        </li>
      </ul>
    </li>
```

- [ ] **Step 2: Verifikasi sintaks ERB Kediri**

Jalankan command verifikasi parsing ERB:
```bash
ruby -eruby_parser -e 'puts "Syntax OK"' || ruby -c app/views/layouts/partials/_stock_kediri.html.erb
```
Atau cek syntax dengan:
```bash
erb -P -x -T '-' app/views/layouts/partials/_stock_kediri.html.erb | ruby -c
```
Expected: `Syntax OK`

- [ ] **Step 3: Commit perubahan Kediri**

```bash
git add app/views/layouts/partials/_stock_kediri.html.erb
git commit -m "feat(stock): add manufacture and normal submenu for classic in kediri sidebar"
```

---

### Task 2: Update Sidebar Partial Jember

**Files:**
- Modify: `app/views/layouts/partials/_stock_jember.html.erb:145-147`

**Interfaces:**
- Consumes: `controller?`, `action?`, `params[:brand]` helpers
- Produces: Collapsible Classic menu dengan item Manufacture dan Normal untuk Jember

- [ ] **Step 1: Edit `app/views/layouts/partials/_stock_jember.html.erb`**

Ganti bagian menu Classic (baris 145-147) dari link tunggal menjadi:
```erb
    <%# CLASSIC %>
    <li class="<%= 'active' if (controller?('stock/jember') && params[:brand] == 'classic') || (controller?('stock/jember/stock_elite') && action?('stock_classic')) %>">
      <a href="#stock-jember-classic" title="Classic" data-toggle="collapse"> <em class="icon-basket-loaded"></em> <span>Classic</span> </a>
      <ul id="stock-jember-classic" class="nav sidebar-subnav collapse">
        <li class="<%= 'active' if controller?('stock/jember') && params[:brand] == 'classic' %>">
          <a href="/stock/jember/classic/normal" title="Manufacture"> <em class="icon-wrench"></em> <span>Manufacture</span> </a>
        </li>
        <li class="<%= 'active' if controller?('stock/jember/stock_elite') && action?('stock_classic') %>">
          <a href="/stock/jember/stock_elite/stock_classic" title="Normal"> <em class="icon-check"></em> <span>Normal</span> </a>
        </li>
      </ul>
    </li>
```

- [ ] **Step 2: Verifikasi sintaks ERB Jember**

Jalankan command verifikasi parsing ERB:
```bash
erb -P -x -T '-' app/views/layouts/partials/_stock_jember.html.erb | ruby -c
```
Expected: `Syntax OK`

- [ ] **Step 3: Commit perubahan Jember**

```bash
git add app/views/layouts/partials/_stock_jember.html.erb
git commit -m "feat(stock): add manufacture and normal submenu for classic in jember sidebar"
```

---

### Task 3: Verifikasi Routing & Controller Endpoints

**Files:**
- Test/Verify: `config/routes.rb`, `app/controllers/stock/kediri_controller.rb`, `app/controllers/stock/jember_controller.rb`

- [ ] **Step 1: Verifikasi route mapping via rails runner / console check**

Jalankan runner script untuk memastikan route controller mengenali action dan parameter yang diharapkan:
```bash
bin/rails runner '
app = ActionDispatch::Integration::Session.new(Rails.application)
routes = [
  "/stock/kediri/classic/normal",
  "/stock/kediri/stock_elite/stock_classic",
  "/stock/jember/classic/normal",
  "/stock/jember/stock_elite/stock_classic"
]
routes.each do |r|
  req = Rails.application.routes.recognize_path(r)
  puts "#{r} => #{req.inspect}"
end
'
```
Expected output:
Semua route berhasil di-recognize ke controller & action masing-masing tanpa routing error.

- [ ] **Step 2: Final git status check**

```bash
git status
```
Expected: working tree clean.
