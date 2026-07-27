# Design Spec: Database Area ID Cleanup & Dynamic Customer Branch Resolution

## Context & Background
In `dbmarketing.tblaporancabang2`, several sales records for `TOTE` (and potentially other brands) have `area_id IS NULL`. This includes customers such as **LAVITA**, **PLAZA MEUBEL**, and **PT ALPINE INDO MANDIRI**. Because `area_id` is missing in these specific rows, sales reports (like `customer_decrease`) failed to map them to their appropriate branch (e.g. `Cabang Makassar`, `area_id = 19`).

To resolve this comprehensively across all customers and all brands, this specification establishes:
1. A database migration/cleanup query to populate `area_id` for NULL records based on existing non-null `area_id` records for the same customer.
2. A dynamic `COALESCE` query fallback in `Penjualan::Customer.customer_decrease` to resolve `area_id` automatically even if future records are inserted with `NULL`.

## Architecture & Data Flow

### 1. Database Cleanup Query
Update all rows in `dbmarketing.tblaporancabang2` where `area_id IS NULL` by matching `kode_customer` to their established non-null `area_id`:
```sql
UPDATE dbmarketing.tblaporancabang2 t1
JOIN (
  SELECT kode_customer, area_id
  FROM dbmarketing.tblaporancabang2
  WHERE area_id IS NOT NULL AND area_id != 0
  GROUP BY kode_customer
) t2 ON t1.kode_customer = t2.kode_customer
SET t1.area_id = t2.area_id
WHERE t1.area_id IS NULL;
```

### 2. Dynamic Query Specification (`Penjualan::Customer.customer_decrease`)
- **File**: `app/models/penjualan/customer.rb`
- **Method**: `Penjualan::Customer.customer_decrease(brand)`
- **SQL Implementation**:
  ```ruby
  def self.customer_decrease(brand)
    date = Date.today
    customer_type_condition = brand == 'TOTE' ? "tipecust IN ('RETAIL', 'ONLINE', 'MODERN', 'DIRECT')" : "tipecust = 'RETAIL'"

    find_by_sql("
      SELECT IFNULL(cb.Cabang, 'PUSAT/RETAIL') AS cabang, b.* FROM (
        SELECT 
          COALESCE(
            MAX(a.area_id),
            (SELECT sub.area_id FROM dbmarketing.tblaporancabang2 sub WHERE sub.kode_customer = a.kode_customer AND sub.area_id IS NOT NULL AND sub.area_id != 0 LIMIT 1)
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

## Impacted Files
- Database: `dbmarketing.tblaporancabang2`
- `app/models/penjualan/customer.rb`
- `app/views/penjualan/template_dashboard/customer_decrease.html.erb`

## Verification Strategy
1. Run the database `UPDATE` query and verify rows for LAVITA, PLAZA MEUBEL, and PT ALPINE INDO MANDIRI have `area_id = 19`.
2. Test `customer_decrease` for `TOTE` and confirm customer records render under `Cabang Makassar` and other respective branches without returning 0 rows.
3. Confirm zero `PUSAT/RETAIL` fallbacks for known branch customers.
