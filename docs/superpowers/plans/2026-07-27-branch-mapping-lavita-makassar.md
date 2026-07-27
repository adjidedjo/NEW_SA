# Standardized Customer Decrease Query across All Brands Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Standardize `Penjualan::Customer.customer_decrease` logic across all brands to match the `ROYAL` brand logic (`tipecust = 'RETAIL'` and `area_id IS NOT NULL`), ensuring LAVITA (area_id 19) and all branch customers map accurately to their respective branches without defaulting to `PUSAT/RETAIL`.

**Architecture:** Refactor `Penjualan::Customer.customer_decrease` in `app/models/penjualan/customer.rb` to remove TOTE-specific query branches, enforcing uniform `tipecust = 'RETAIL'` and `area_id IS NOT NULL` filters with dynamic `LEFT JOIN dbmarketing.tbidcabang cb ON cb.id = b.area_id`.

**Tech Stack:** Ruby on Rails 4.x / 5.x, MySQL (MariaDB), ERB templates.

## Global Constraints
- Standardize all brands (`ROYAL`, `ELITE`, `LADY`, `SERENITY`, `TOTE`) under a single SQL query structure.
- Enforce `tipecust = 'RETAIL'` and `AND area_id IS NOT NULL` across all brand invocations.
- No hardcoded customer codes or branch names.

---

### Task 1: Refactor `Penjualan::Customer.customer_decrease` to Standardize Query Logic

**Files:**
- Modify: `app/models/penjualan/customer.rb:16-39`

**Interfaces:**
- Consumes: `brand` string parameter (e.g. `'ROYAL'`, `'ELITE'`, `'LADY'`, `'SERENITY'`, `'TOTE'`)
- Produces: ActiveRecord query result with `.cabang` mapped via `tbidcabang.Cabang`.

- [ ] **Step 1: Write/Update unit test in `test/models/penjualan/customer_test.rb` for all brands**

```ruby
require 'test_helper'

class Penjualan::CustomerTest < ActiveSupport::TestCase
  test "customer_decrease produces consistent branch mapping for ROYAL and TOTE" do
    %w[ROYAL ELITE LADY SERENITY TOTE].each do |brand|
      results = Penjualan::Customer.customer_decrease(brand)
      assert results.is_a?(Enumerable), "Expected query result for #{brand}"
      
      # Ensure no records contain area_id IS NULL that fallback unexpectedly
      results.each do |record|
        assert_not_nil record.cabang, "Cabang should not be nil for #{record.customer}"
      end
    end
  end
end
```

- [ ] **Step 2: Update `Penjualan::Customer.customer_decrease` in `app/models/penjualan/customer.rb`**

Replace lines 16-39 in `app/models/penjualan/customer.rb`:

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
              AND area_id IS NOT NULL
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

- [ ] **Step 3: Run Python verification script across all 5 brands**

Run:
```bash
python3 -c "
import mysql.connector

conn = mysql.connector.connect(host='dbsaltic.royalcorp.co.id', user='root', password='Roy@l4b@d!', database='dbmarketing')
cursor = conn.cursor(dictionary=True)

for brand in ['ROYAL', 'ELITE', 'LADY', 'SERENITY', 'TOTE']:
    query = f'''
      SELECT IFNULL(cb.Cabang, \"PUSAT/RETAIL\") AS cabang, b.* FROM (
        SELECT a.area_id, a.customer, a.kode_customer, a.jenisbrgdisc, a.kota
        FROM (
          SELECT jenisbrgdisc, area_id, customer, kode_customer, kota, harganetto2, WEEK, fiscal_year
          FROM dbmarketing.tblaporancabang2
          WHERE tanggalsj BETWEEN '2026-06-22' AND '2026-07-19' 
            AND jenisbrgdisc REGEXP '{brand}' 
            AND tipecust = 'RETAIL'
            AND area_id IS NOT NULL
        ) a GROUP BY a.customer, a.jenisbrgdisc
      ) b
      LEFT JOIN dbmarketing.tbidcabang cb ON cb.id = b.area_id
      ORDER BY b.customer
    '''
    cursor.execute(query)
    rows = cursor.fetchall()
    pusat_count = len([r for r in rows if r['cabang'] == 'PUSAT/RETAIL'])
    print(f'Brand: {brand:<10} | Rows: {len(rows):<4} | PUSAT/RETAIL Count: {pusat_count}')
"
```
Expected output: PUSAT/RETAIL Count: 0 for all brands.

- [ ] **Step 4: Commit**

```bash
git add app/models/penjualan/customer.rb
git commit -m "refactor(penjualan): standardize customer_decrease query for all brands to match royal brand"
```

---

### Task 2: Verify View Template Rendering Across All Brands

**Files:**
- Modify: `app/views/penjualan/template_dashboard/customer_decrease.html.erb`

**Interfaces:**
- Consumes: `@customer` array of ActiveRecord results.
- Produces: Clean HTML table rendering `Cabang Makassar` (or other branch names) without `PUSAT/RETAIL`.

- [ ] **Step 1: Check view template syntax**

Run: `ruby -r erb -e "puts ERB.new(File.read('app/views/penjualan/template_dashboard/customer_decrease.html.erb')).src" | ruby -c`
Expected: `Syntax OK`

- [ ] **Step 2: Commit view template verification**

```bash
git add app/views/penjualan/template_dashboard/customer_decrease.html.erb
git commit -m "fix(view): confirm customer_decrease view template compatibility"
```
