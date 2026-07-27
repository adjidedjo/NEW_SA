# Design Spec: Dynamic Branch Mapping for Makassar & LAVITA Customer

## Context & Background
In the sales reporting system (`NEW_SA`), branch mapping for sales transactions stored in `dbmarketing.tblaporancabang2` relies on relational mapping using `area_id` linked to `dbmarketing.tbidcabang`. Customer **LAVITA** (`kode_customer: 101383`) is located in Makassar with `area_id = 19`, which corresponds to `Cabang Makassar` in `tbidcabang`.

Recent updates on the `master2` branch introduced weekly comparison metrics and indicators on the `customer_decrease` view. To prevent template errors and ensure all customers (including LAVITA) correctly map to their respective branches without hardcoding customer or branch names, a dynamic SQL `LEFT JOIN` pattern with safe fallback handling is established.

## Architecture & Data Flow
1. **Dynamic Mapping Principle**:
   - Branch names are derived dynamically from `dbmarketing.tbidcabang` via `area_id`.
   - Hardcoding specific customer codes or branch names in Ruby model logic or ERB views is strictly avoided.
2. **Data Pipeline**:
   ```
   [tblaporancabang2] (Customer: LAVITA, area_id: 19)
         │
         ▼
   [Weekly/Monthly Sales Aggregation Subquery]
         │
         ▼
   [LEFT JOIN dbmarketing.tbidcabang ON tbidcabang.id = area_id]
         │
         ▼
   [IFNULL(cb.Cabang, 'PUSAT/RETAIL')] ──► Outputs: "Cabang Makassar"
         │
         ▼
   [Controller / ERB Template] ──► Render with safe string conversion (.to_s)
   ```

## Query Specification & Fallback Mechanics
- **Model**: `Penjualan::Customer.customer_decrease(brand)`
- **SQL Structure**:
  ```sql
  SELECT IFNULL(cb.Cabang, 'PUSAT/RETAIL') AS cabang, b.* FROM (
    SELECT a.area_id, a.customer, a.kode_customer, a.jenisbrgdisc, a.kota,
      IFNULL(SUM(CASE WHEN a.week = '#{4.weeks.ago.to_date.cweek}' AND a.fiscal_year = '#{4.weeks.ago.to_date.year}' THEN a.harganetto2 END), 0) AS w4,
      IFNULL(SUM(CASE WHEN a.week = '#{3.weeks.ago.to_date.cweek}' AND a.fiscal_year = '#{3.weeks.ago.to_date.year}' THEN a.harganetto2 END), 0) AS w3,
      IFNULL(SUM(CASE WHEN a.week = '#{2.weeks.ago.to_date.cweek}' AND a.fiscal_year = '#{2.weeks.ago.to_date.year}' THEN a.harganetto2 END), 0) AS w2,
      IFNULL(SUM(CASE WHEN a.week = '#{1.weeks.ago.to_date.cweek}' AND a.fiscal_year = '#{1.weeks.ago.to_date.year}' THEN a.harganetto2 END), 0) AS w1
      FROM (
        SELECT jenisbrgdisc, area_id, customer, kode_customer, kota, harganetto2, week, fiscal_year
        FROM dbmarketing.tblaporancabang2
        WHERE tanggalsj BETWEEN '#{5.weeks.ago.to_date}' AND '#{1.weeks.ago.end_of_week.to_date}' 
          AND jenisbrgdisc REGEXP '#{brand}' 
          AND #{customer_type_condition}
          #{area_condition}
      ) a GROUP BY a.customer, a.jenisbrgdisc
  ) b
  LEFT JOIN dbmarketing.tbidcabang cb ON cb.id = b.area_id
  ORDER BY b.customer
  ```
- **Fallback Rules**:
  - `customer_type_condition`: For brand `TOTE`, includes `('RETAIL', 'ONLINE', 'MODERN', 'DIRECT')`. For other brands (e.g. `ELITE`), strictly `'RETAIL'`.
  - If `b.area_id` is `NULL` or not found in `tbidcabang`, `IFNULL(cb.Cabang, 'PUSAT/RETAIL')` ensures a valid non-nil string is returned.
  - In ERB templates, branch name access utilizes safe string conversion (`.to_s`) to remain compatible across environments.

## Impacted Files
- `app/models/penjualan/customer.rb`
- `app/views/penjualan/customers/customer_decrease.html.erb`

## Verification & Validation Strategy
1. Verify database mapping for LAVITA (`kode_customer: 101383`) returns `area_id = 19` and resolves to `"Cabang Makassar"`.
2. Ensure no ERB template errors (`NilClass` exceptions) occur when rendering customer decrease lists.
3. Validate query execution with both `TOTE` and non-`TOTE` brands.
