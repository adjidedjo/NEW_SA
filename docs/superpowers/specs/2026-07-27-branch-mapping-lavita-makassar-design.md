# Design Spec: Standardized Customer Decrease Query across All Brands (Identical to Royal)

## Context & Background
In the sales reporting system (`NEW_SA`), the `customer_decrease` feature displays weekly customer revenue decrease metrics per brand (`ROYAL`, `ELITE`, `LADY`, `SERENITY`, `TOTE`). 

Previously, `brand == 'TOTE'` had custom conditions that bypassed `tipecust = 'RETAIL'` and `area_id IS NOT NULL`, allowing null `area_id` transactions to pollute the results and render as `PUSAT/RETAIL`. In contrast, the `ROYAL` brand query strictly filters `tipecust = 'RETAIL'` and `area_id IS NOT NULL`, which correctly maps customer **LAVITA** (`area_id = 19`) to `Cabang Makassar`.

This specification standardizes all brand queries to match the proven, clean logic of the `ROYAL` brand.

## Architecture & Data Flow
1. **Uniform Query Rule**:
   - All brand pages (`ROYAL`, `ELITE`, `LADY`, `SERENITY`, `TOTE`) run the identical query pattern.
   - Filters strictly enforce `tipecust = 'RETAIL'` and `area_id IS NOT NULL`.
   - `LEFT JOIN dbmarketing.tbidcabang cb ON cb.id = b.area_id` maps `area_id = 19` to `Cabang Makassar` without hardcoding.

2. **Data Pipeline**:
   ```
   [tblaporancabang2] ──► Filter: jenisbrgdisc REGEXP '#{brand}' AND tipecust = 'RETAIL' AND area_id IS NOT NULL
         │
         ▼
   [Weekly Sales Aggregation Subquery] (Group by customer, jenisbrgdisc)
         │
         ▼
   [LEFT JOIN dbmarketing.tbidcabang ON tbidcabang.id = area_id]
         │
         ▼
   [IFNULL(cb.Cabang, 'PUSAT/RETAIL')] ──► Returns: "Cabang Makassar" for LAVITA (area_id = 19)
         │
         ▼
   [Template View] ──► Render <%= dp.cabang.to_s.gsub('Cabang', '') %>
   ```

## Query Specification
- **File**: `app/models/penjualan/customer.rb`
- **Method**: `Penjualan::Customer.customer_decrease(brand)`
- **SQL Implementation**:
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

## Impacted Files
- `app/models/penjualan/customer.rb`
- `app/views/penjualan/template_dashboard/customer_decrease.html.erb`

## Verification Strategy
1. Verify query execution across `ROYAL`, `ELITE`, `LADY`, `SERENITY`, and `TOTE` brands.
2. Confirm LAVITA records map to `Cabang Makassar`.
3. Confirm zero records return with `PUSAT/RETAIL` when `area_id IS NOT NULL` is enforced.
