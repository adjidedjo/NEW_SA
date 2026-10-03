# Customer Decrease Table and Export Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menghapus kolom selisih dan memperbaiki ekspor Excel/CSV pada halaman Customer Decrease agar file hasil export dapat dibuka dengan normal tanpa corrupt.

**Architecture:** Modifikasi template view ERB `customer_decrease.html.erb` untuk menghapus 3 kolom selisih (`<thead>` dan `<tbody>`), menghilangkan karakter unicode non-ASCII (`➔`) dan tag HTML styling yang sebelumnya merusak generator XML/JSZip pada ekspor DataTables.

**Tech Stack:** Ruby on Rails (ERB), DataTables HTML5 Buttons (JSZip, CSV export), jQuery

## Global Constraints
- Target View: `app/views/penjualan/template_dashboard/customer_decrease.html.erb`
- Total kolom tabel setelah update: 8 kolom (`Branch`, `Brand`, `Customer`, `City`, `Week 4`, `Week 3`, `Week 2`, `Week 1`)
- Tidak merusak fungsionalitas DataTables `#table-revenue-products`

---

### Task 1: Update Template View Customer Decrease

**Files:**
- Modify: `app/views/penjualan/template_dashboard/customer_decrease.html.erb`

**Interfaces:**
- Consumes: `@customer` ActiveRecord / OpenStruct collection dengan atribut `cabang`, `jenisbrgdisc`, `customer`, `kota`, `w4`, `w3`, `w2`, `w1`.
- Produces: 8-column HTML table with clean text content for DataTables rendering and HTML5 export.

- [ ] **Step 1: Check existing view content and line structure**

Run: `cat app/views/penjualan/template_dashboard/customer_decrease.html.erb`

- [ ] **Step 2: Update `customer_decrease.html.erb`**

Ganti isi `app/views/penjualan/template_dashboard/customer_decrease.html.erb` agar hanya menampilkan 8 kolom tanpa kolom selisih dan tanpa variabel `diff_*`:

```erb
<div class="content-heading">
  <b>CUSTOMER DECREASE</b>
</div>
<!-- START widgets box-->
<!-- END widgets box-->
<div class="row">
  <!-- START dashboard main content-->
  <div class="col-lg-12">
    <!-- START content-->
    <div class="row">
      <div class="col-lg-12">
        <div class="panel panel-info">
          <div class="panel-heading" style="text-align: center">
            Total Revenue
          </div>
          <div class="panel-body">
            <table id="table-revenue-products" class="table table-striped table-hover">
              <thead>
                <tr>
                  <th>Branch</th>
                  <th>Brand</th>
                  <th>Customer</th>
                  <th>City</th>
                  <th>Week <%= 4.weeks.ago.to_date.cweek %> <br /><%= week_c(4) %></th>
                  <th>Week <%= 3.weeks.ago.to_date.cweek %> <br /><%= week_c(3) %></th>
                  <th>Week <%= 2.weeks.ago.to_date.cweek %> <br /><%= week_c(2) %></th>
                  <th>Week <%= 1.weeks.ago.to_date.cweek %> <br /><%= week_c(1) %></th>
                </tr>
              </thead>
              <tbody>
                <% @customer.each do |dp| %>
                <tr class="gradeX">
                  <td><%= dp.cabang.to_s.gsub('Cabang', '') %></td>
                  <td><%= dp.jenisbrgdisc %></td>
                  <td><%= dp.customer %></td>
                  <td><%= dp.kota %></td>
                  <td><%= currency(dp.w4) %></td>
                  <td><%= currency(dp.w3) %></td>
                  <td><%= currency(dp.w2) %></td>
                  <td><%= currency(dp.w1) %></td>
                </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    <!-- END content-->
  </div>
</div>
```

- [ ] **Step 3: Verify ERB syntax**

Run: `ruby -e "require 'erb'; ERB.new(File.read('app/views/penjualan/template_dashboard/customer_decrease.html.erb')).src"`
Expected: No syntax errors returned.

- [ ] **Step 4: Commit changes**

```bash
git add app/views/penjualan/template_dashboard/customer_decrease.html.erb
git commit -m "fix(penjualan): remove difference columns and fix excel export on customer decrease"
```

---

### Task 2: Verification of Data & Export Integration

**Files:**
- Inspect: `app/views/penjualan/template_dashboard/customer_decrease.html.erb`
- Inspect: `app/assets/javascripts/angle/modules/demo/demo-datatable.js`

- [ ] **Step 1: Check table ID and column count symmetry**

Verify that `<th>` count (8) exactly matches `<td>` count (8) in `app/views/penjualan/template_dashboard/customer_decrease.html.erb`.

- [ ] **Step 2: Check git diff and log**

Run: `git diff HEAD~1`
Expected: Diff shows clean removal of `<th>Selisih...` and `<td>` difference logic.
