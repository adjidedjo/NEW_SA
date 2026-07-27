# Database Area ID Cleanup & Dynamic Customer Branch Resolution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clean up missing `area_id` values in `dbmarketing.tblaporancabang2` and add dynamic `COALESCE` customer `area_id` resolution in `Penjualan::Customer.customer_decrease`, ensuring LAVITA, PLAZA MEUBEL, PT ALPINE INDO MANDIRI, DEPO PELITA PURWOKERTO, and all other customers display accurately under their respective branches across all brands.

**Architecture:** 
1. Run SQL `UPDATE` on `dbmarketing.tblaporancabang2` to populate `area_id` for NULL rows based on existing non-null `area_id` records for each `kode_customer`.
2. Update `Penjualan::Customer.customer_decrease` in `app/models/penjualan/customer.rb` with dynamic `COALESCE` `resolved_area_id` logic and `customer_type_condition` for `TOTE` (`tipecust IN ('RETAIL', 'ONLINE', 'MODERN', 'DIRECT')`).

**Tech Stack:** Ruby on Rails 4.x / 5.x, MySQL (MariaDB), ERB templates.

## Global Constraints
- Clean up database `area_id` NULL rows safely.
- Implement dynamic fallback for `area_id` resolution.
- Ensure `customer_decrease` for `TOTE` returns non-zero results with mapped branches.

---

### Task 1: Execute Database `area_id` Cleanup Query

**Files:**
- Database: `dbmarketing.tblaporancabang2`

**Interfaces:**
- Consumes: `kode_customer` matching between NULL and non-NULL `area_id` records.
- Produces: Populated `area_id` for NULL rows in `tblaporancabang2`.

- [ ] **Step 1: Execute SQL UPDATE query on `dbmarketing.tblaporancabang2`**

Run:
```bash
python3 -c "
import mysql.connector

conn = mysql.connector.connect(host='192.213.213.101', user='root', password='Roy@l4b@d!', database='dbmarketing')
cursor = conn.cursor()

update_query = '''
UPDATE dbmarketing.tblaporancabang2 t1
JOIN (
  SELECT kode_customer, area_id
  FROM dbmarketing.tblaporancabang2
  WHERE area_id IS NOT NULL AND area_id != 0
  GROUP BY kode_customer
) t2 ON t1.kode_customer = t2.kode_customer
SET t1.area_id = t2.area_id
WHERE t1.area_id IS NULL;
'''
cursor.execute(update_query)
conn.commit()
print('Affected rows:', cursor.rowcount)
"
```

- [ ] **Step 2: Verify `area_id` values for LAVITA, PLAZA MEUBEL, PT ALPINE INDO MANDIRI, DEPO PELITA PURWOKERTO**

Run:
```bash
python3 -c "
import mysql.connector

conn = mysql.connector.connect(host='192.213.213.101', user='root', password='Roy@l4b@d!', database='dbmarketing')
cursor = conn.cursor(dictionary=True)

query = '''
SELECT customer, kode_customer, area_id, COUNT(*) as row_count
FROM dbmarketing.tblaporancabang2
WHERE customer IN ('LAVITA', 'PLAZA MEUBEL', 'PT ALPINE INDO MANDIRI', 'DEPO PELITA PURWOKERTO')
GROUP BY customer, area_id;
'''
cursor.execute(query)
for r in cursor.fetchall():
    print(r)
"
```
Expected: All row groups display valid `area_id` (e.g. 19 for LAVITA, PLAZA MEUBEL, ALPINE).

---

### Task 2: Implement Dynamic `resolved_area_id` in `Penjualan::Customer.customer_decrease`

**Files:**
- Modify: `app/models/penjualan/customer.rb:16-45`

**Interfaces:**
- Consumes: `brand` string parameter.
- Produces: ActiveRecord query results with `.cabang` mapped via `tbidcabang.Cabang`.

- [ ] **Step 1: Update `Penjualan::Customer.customer_decrease` in `app/models/penjualan/customer.rb`**

Update `customer_decrease` in `app/models/penjualan/customer.rb`:

```ruby
  def self.customer_decrease(brand)
    date = Date.today
    customer_type_condition = brand == 'TOTE' ? "tipecust IN ('RETAIL', 'ONLINE', 'MODERN', 'DIRECT')" : "tipecust = 'RETAIL'"

    find_by_sql("
      SELECT IFNULL(cb.Cabang, 'PUSAT/RETAIL') AS cabang, b.* FROM (
        SELECT 
          COALESCE(
            MAX(a.area_id),
            (SELECT sub.area_id FROM dbmarketing.tblaporancabang2 sub WHERE sub.kode_customer = a.kode_customer AND sub.area_id IS NOT NULL AND sub.area_id != 0 ORDER BY sub.tanggalsj DESC LIMIT 1)
          ) AS resolved_area_id,
          a.customer, a.kode_customer, a.jenisbrgdisc, a.kota,
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
          ) a GROUP BY a.customer, a.jenisbrgdisc
      ) b
      LEFT JOIN dbmarketing.tbidcabang cb ON cb.id = b.resolved_area_id
      ORDER BY b.customer
    ")
  end
```

- [ ] **Step 2: Run verification script across all 5 brands (ROYAL, ELITE, LADY, SERENITY, TOTE)**

Run:
```bash
python3 -c "
import mysql.connector

conn = mysql.connector.connect(host='192.213.213.101', user='root', password='Roy@l4b@d!', database='dbmarketing')
cursor = conn.cursor(dictionary=True)

for brand in ['ROYAL', 'ELITE', 'LADY', 'SERENITY', 'TOTE']:
    customer_type_condition = \"tipecust IN ('RETAIL', 'ONLINE', 'MODERN', 'DIRECT')\" if brand == 'TOTE' else \"tipecust = 'RETAIL'\"
    query = f'''
      SELECT IFNULL(cb.Cabang, \"PUSAT/RETAIL\") AS cabang, b.* FROM (
        SELECT 
          COALESCE(
            MAX(a.area_id),
            (SELECT sub.area_id FROM dbmarketing.tblaporancabang2 sub WHERE sub.kode_customer = a.kode_customer AND sub.area_id IS NOT NULL AND sub.area_id != 0 ORDER BY sub.tanggalsj DESC LIMIT 1)
          ) AS resolved_area_id,
          a.customer, a.kode_customer, a.jenisbrgdisc, a.kota
          FROM (
            SELECT jenisbrgdisc, area_id, customer, kode_customer, kota, harganetto2, WEEK, fiscal_year
            FROM dbmarketing.tblaporancabang2
            WHERE tanggalsj BETWEEN '2026-06-22' AND '2026-07-19' 
              AND jenisbrgdisc REGEXP '{brand}' 
              AND {customer_type_condition}
          ) a GROUP BY a.customer, a.jenisbrgdisc
      ) b
      LEFT JOIN dbmarketing.tbidcabang cb ON cb.id = b.resolved_area_id
      ORDER BY b.customer
    '''
    cursor.execute(query)
    rows = cursor.fetchall()
    pusat_count = len([r for r in rows if r['cabang'] == 'PUSAT/RETAIL'])
    print(f'Brand: {brand:<10} | Rows: {len(rows):<4} | PUSAT/RETAIL Count: {pusat_count}')
"
```
Expected: All 5 brands return non-zero rows (TOTE returns ~62 rows), and PUSAT/RETAIL Count is minimized/zero.

- [ ] **Step 3: Commit**

```bash
git add app/models/penjualan/customer.rb
git commit -m "feat(penjualan): add dynamic resolved_area_id and multi-tipecust for TOTE in customer_decrease"
```

---

### Task 3: Verify View Template Compatibility

**Files:**
- Modify: `app/views/penjualan/template_dashboard/customer_decrease.html.erb`

- [ ] **Step 1: Run ERB syntax verification**

Run: `ruby -r erb -e "puts ERB.new(File.read('app/views/penjualan/template_dashboard/customer_decrease.html.erb')).src" | ruby -c`
Expected: `Syntax OK`

- [ ] **Step 2: Commit view template verification**

```bash
git add app/views/penjualan/template_dashboard/customer_decrease.html.erb
git commit -m "fix(view): verify ERB template compatibility for customer decrease"
```
