# Fix Customer Decrease Page Data for Brand TOTE Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix empty data bug on `/penjualan/nasional/nasional_tote/customer_decrease` page by modifying `Penjualan::Customer.customer_decrease` to query TOTE customer sales correctly (including ONLINE, MODERN, DIRECT) and handling NULL branch areas safely.

**Architecture:** Update `Penjualan::Customer.customer_decrease(brand)` in `app/models/penjualan/customer.rb` to dynamically adjust `tipecust` and `area_id` filtering when `brand == 'TOTE'`, and update `app/views/penjualan/template_dashboard/customer_decrease.html.erb` with safe navigation for branch names.

**Tech Stack:** Ruby 2.5.8, Rails 5, MySQL (`dbmarketing.tblaporancabang2`).

## Global Constraints

- Preserve existing `tipecust = 'RETAIL'` behavior for other brands (`ELITE`, `LADY`, `ROYAL`, `SERENITY`).
- Handle NULL `area_id` values seamlessly without raising `NoMethodError` on `nil.gsub`.

---

### Task 1: Update `Penjualan::Customer.customer_decrease` SQL query in `app/models/penjualan/customer.rb`

**Files:**
- Modify: `app/models/penjualan/customer.rb:16-39`

**Interfaces:**
- Consumes: `brand` String (`"TOTE"`, `"ELITE"`, `"LADY"`, `"ROYAL"`, `"SERENITY"`)
- Produces: `ActiveRecord::Result` collection with attributes `cabang`, `area_id`, `customer`, `kode_customer`, `jenisbrgdisc`, `kota`, `w4`, `w3`, `w2`, `w1`

- [ ] **Step 1: Inspect current implementation of `self.customer_decrease`**

Check lines 16-39 of `app/models/penjualan/customer.rb`.

- [ ] **Step 2: Modify `self.customer_decrease` method in `app/models/penjualan/customer.rb`**

Update `self.customer_decrease(brand)` to:
```ruby
  def self.customer_decrease(brand)
    date = Date.today
    customer_type_condition = brand == 'TOTE' ? "tipecust IN ('RETAIL', 'ONLINE', 'MODERN', 'DIRECT')" : "tipecust = 'RETAIL'"
    area_condition = brand == 'TOTE' ? "" : "AND area_id IS NOT NULL"

    find_by_sql("
      SELECT IFNULL(cb.Cabang, 'ONLINE/PUSAT') AS cabang, b.* FROM (
        SELECT a.area_id, a.customer, a.kode_customer, a.jenisbrgdisc, a.kota,
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
            #{area_condition}
          ) a GROUP BY a.customer, a.jenisbrgdisc
      ) b
      LEFT JOIN
      (
        SELECT * FROM dbmarketing.tbidcabang
      ) cb ON cb.id = b.area_id
      ORDER BY b.customer
    ")
  end
```

- [ ] **Step 3: Run rails runner verification script**

Run: `/usr/share/rvm/bin/rvm 2.5.8 do bundle exec rails runner "puts 'TOTE count: ' + Penjualan::Customer.customer_decrease('TOTE').to_a.size.to_s; puts 'ELITE count: ' + Penjualan::Customer.customer_decrease('ELITE').to_a.size.to_s"`
Expected: TOTE count > 0, ELITE count = 269.

- [ ] **Step 4: Commit changes**

```bash
git add app/models/penjualan/customer.rb
git commit -m "fix(penjualan): adjust customer_decrease query for TOTE brand customer types"
```

---

### Task 2: Add safe navigation to `app/views/penjualan/template_dashboard/customer_decrease.html.erb`

**Files:**
- Modify: `app/views/penjualan/template_dashboard/customer_decrease.html.erb:33`

**Interfaces:**
- Consumes: `@customer` record set from controller
- Produces: HTML table view with safe branch name rendering

- [ ] **Step 1: Update view file line 33**

In `app/views/penjualan/template_dashboard/customer_decrease.html.erb`:
Replace line 33:
```erb
                  <td><%= dp.cabang.gsub('Cabang', '') %></td>
```
With:
```erb
                  <td><%= dp.cabang&.gsub('Cabang', '') %></td>
```

- [ ] **Step 2: Verify view template rendering**

Run: `/usr/share/rvm/bin/rvm 2.5.8 do bundle exec rails runner "controller = Penjualan::Nasional::NasionalToteController.new; controller.params = {}; customers = Penjualan::Customer.customer_decrease('TOTE'); customers.each { |dp| puts dp.cabang&.gsub('Cabang', '') }"`
Expected: Prints branch names without error.

- [ ] **Step 3: Commit changes**

```bash
git add app/views/penjualan/template_dashboard/customer_decrease.html.erb
git commit -m "fix(view): add safe navigation operator for branch name in customer_decrease template"
```
