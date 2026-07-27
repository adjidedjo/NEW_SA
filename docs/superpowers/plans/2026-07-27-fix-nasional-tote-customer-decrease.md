# Fix Customer Decrease Page Data (Strictly RETAIL) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix empty data bug on `/penjualan/nasional/nasional_tote/customer_decrease` for RETAIL customers by removing `AND area_id IS NOT NULL` restriction and handling NULL branch areas safely in `Penjualan::Customer.customer_decrease`.

**Architecture:** Update `Penjualan::Customer.customer_decrease(brand)` in `app/models/penjualan/customer.rb` to remove `AND area_id IS NOT NULL` constraint while keeping `tipecust = 'RETAIL'`, and ensure `app/views/penjualan/template_dashboard/customer_decrease.html.erb` uses safe navigation for branch names.

**Tech Stack:** Ruby 2.5.8, Rails 5, MySQL (`dbmarketing.tblaporancabang2`).

## Global Constraints

- Keep `tipecust = 'RETAIL'` for all brands.
- Remove `AND area_id IS NOT NULL` so transactions with `area_id = NULL` are included.
- Use `IFNULL(cb.Cabang, 'PUSAT/RETAIL')` for fallback branch name.

---

### Task 1: Update `Penjualan::Customer.customer_decrease` SQL query in `app/models/penjualan/customer.rb`

**Files:**
- Modify: `app/models/penjualan/customer.rb:16-39`

**Interfaces:**
- Consumes: `brand` String (`"TOTE"`, `"ELITE"`, `"LADY"`, `"ROYAL"`, `"SERENITY"`)
- Produces: `ActiveRecord::Result` collection with RETAIL customer decrease records

- [ ] **Step 1: Modify `self.customer_decrease` method in `app/models/penjualan/customer.rb`**

Update `self.customer_decrease(brand)` to:
```ruby
  def self.customer_decrease(brand)
    date = Date.today

    find_by_sql("
      SELECT IFNULL(cb.Cabang, 'PUSAT/RETAIL') AS cabang, b.* FROM (
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
            AND tipecust = 'RETAIL'
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

- [ ] **Step 2: Run rails runner verification script**

Run: `/usr/share/rvm/bin/rvm 2.5.8 do bundle exec rails runner "puts 'TOTE RETAIL count: ' + Penjualan::Customer.customer_decrease('TOTE').to_a.size.to_s; puts 'ELITE RETAIL count: ' + Penjualan::Customer.customer_decrease('ELITE').to_a.size.to_s"`
Expected: TOTE RETAIL count = 4, ELITE RETAIL count = 269.

- [ ] **Step 3: Commit changes**

```bash
git add app/models/penjualan/customer.rb
git commit -m "fix(penjualan): remove area_id IS NOT NULL constraint in customer_decrease for RETAIL customers"
```

---

### Task 2: Ensure safe navigation in `app/views/penjualan/template_dashboard/customer_decrease.html.erb`

**Files:**
- Modify: `app/views/penjualan/template_dashboard/customer_decrease.html.erb:33`

**Interfaces:**
- Consumes: `@customer` record set
- Produces: HTML table view with safe branch rendering

- [ ] **Step 1: Check view file line 33**

Ensure line 33 in `app/views/penjualan/template_dashboard/customer_decrease.html.erb` uses safe navigation:
```erb
                  <td><%= dp.cabang&.gsub('Cabang', '') %></td>
```

- [ ] **Step 2: Run verification script**

Run: `/usr/share/rvm/bin/rvm 2.5.8 do bundle exec rails runner "customers = Penjualan::Customer.customer_decrease('TOTE'); customers.each { |dp| puts dp.customer + ' (' + (dp.cabang&.gsub('Cabang', '') || '') + ')' }"`
Expected: Prints all 4 TOTE RETAIL customers with their branch name cleanly.

- [ ] **Step 3: Commit changes**

```bash
git add app/views/penjualan/template_dashboard/customer_decrease.html.erb
git commit -m "fix(view): ensure safe navigation for branch name in customer_decrease view"
```
