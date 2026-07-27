# Fix Customer Decrease ERB Syntax Error Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix ERB SyntaxError in production by replacing `&.` in `customer_decrease.html.erb` with `.to_s.gsub('Cabang', '')`.

**Architecture:** Update `app/views/penjualan/template_dashboard/customer_decrease.html.erb` line 33 to use `dp.cabang.to_s.gsub('Cabang', '')`.

**Tech Stack:** Ruby 2.5.8 / Rails ERB.

## Global Constraints

- Replace `&.` with `.to_s.gsub(...)` to ensure compatibility with ERB parser in production.

---

### Task 1: Update `app/views/penjualan/template_dashboard/customer_decrease.html.erb` to use `.to_s`

**Files:**
- Modify: `app/views/penjualan/template_dashboard/customer_decrease.html.erb:33`

**Interfaces:**
- Consumes: `@customer` record set
- Produces: Valid ERB HTML table rendering without syntax errors

- [ ] **Step 1: Modify line 33 in `app/views/penjualan/template_dashboard/customer_decrease.html.erb`**

Replace:
```erb
                  <td><%= dp.cabang&.gsub('Cabang', '') %></td>
```
With:
```erb
                  <td><%= dp.cabang.to_s.gsub('Cabang', '') %></td>
```

- [ ] **Step 2: Verify ERB compilation and output**

Run: `/usr/share/rvm/bin/rvm 2.5.8 do bundle exec rails runner "customers = Penjualan::Customer.customer_decrease('TOTE'); customers.each { |dp| puts dp.customer + ' (' + dp.cabang.to_s.gsub('Cabang', '') + ')' }"`
Expected: Clean output for all 4 TOTE RETAIL customers without any syntax or runtime errors.

- [ ] **Step 3: Commit changes**

```bash
git add app/views/penjualan/template_dashboard/customer_decrease.html.erb
git commit -m "fix(view): use to_s instead of safe navigation in ERB for production compatibility"
```
