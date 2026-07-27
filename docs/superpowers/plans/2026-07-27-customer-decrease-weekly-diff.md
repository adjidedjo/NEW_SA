# Customer Decrease Weekly Change Columns Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add weekly change columns (W4➔W3, W3➔W2, W2➔W1) with color indicators to the customer decrease view template.

**Architecture:** Update `app/views/penjualan/template_dashboard/customer_decrease.html.erb` to calculate and display differences between consecutive weeks with Bootstrap text-danger/text-success classes and FontAwesome caret icons.

**Tech Stack:** Rails ERB, Bootstrap CSS, FontAwesome icons.

## Global Constraints

- Use `currency(val)` for formatting monetary amounts.
- Use `to_s` when calling `.gsub` or string methods in ERB tags to ensure ERB compatibility in production.
- Display `<span class="text-danger"><i class="fa fa-caret-down"></i> <%= currency(diff) %></span>` for negative diffs.
- Display `<span class="text-success"><i class="fa fa-caret-up"></i> <%= currency(diff) %></span>` for positive diffs.
- Display `-` for zero diffs.

---

### Task 1: Add Weekly Change Columns in `customer_decrease.html.erb`

**Files:**
- Modify: `app/views/penjualan/template_dashboard/customer_decrease.html.erb:18-43`

**Interfaces:**
- Consumes: `@customer` records with `w4`, `w3`, `w2`, `w1`
- Produces: Enhanced HTML table with 11 columns

- [ ] **Step 1: Update Table Headers and Body in `customer_decrease.html.erb`**

Update `app/views/penjualan/template_dashboard/customer_decrease.html.erb`:
```erb
<div class="content-heading">
  <b>CUSTOMER DECREASE</b>
</div>
<div class="row">
  <div class="col-lg-12">
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
                  <th>Selisih (W4➔W3)</th>
                  <th>Week <%= 2.weeks.ago.to_date.cweek %> <br /><%= week_c(2) %></th>
                  <th>Selisih (W3➔W2)</th>
                  <th>Week <%= 1.weeks.ago.to_date.cweek %> <br /><%= week_c(1) %></th>
                  <th>Selisih (W2➔W1)</th>
                </tr>
              </thead>
              <tbody>
                <% @customer.each do |dp| %>
                <% 
                  diff_34 = dp.w3.to_f - dp.w4.to_f
                  diff_23 = dp.w2.to_f - dp.w3.to_f
                  diff_12 = dp.w1.to_f - dp.w2.to_f
                %>
                <tr class="gradeX">
                  <td><%= dp.cabang.to_s.gsub('Cabang', '') %></td>
                  <td><%= dp.jenisbrgdisc %></td>
                  <td><%= dp.customer %></td>
                  <td><%= dp.kota %></td>
                  <td><%= currency(dp.w4) %></td>
                  <td><%= currency(dp.w3) %></td>
                  <td>
                    <% if diff_34 < 0 %>
                      <span class="text-danger"><i class="fa fa-caret-down"></i> <%= currency(diff_34) %></span>
                    <% elsif diff_34 > 0 %>
                      <span class="text-success"><i class="fa fa-caret-up"></i> +<%= currency(diff_34) %></span>
                    <% else %>
                      -
                    <% end %>
                  </td>
                  <td><%= currency(dp.w2) %></td>
                  <td>
                    <% if diff_23 < 0 %>
                      <span class="text-danger"><i class="fa fa-caret-down"></i> <%= currency(diff_23) %></span>
                    <% elsif diff_23 > 0 %>
                      <span class="text-success"><i class="fa fa-caret-up"></i> +<%= currency(diff_23) %></span>
                    <% else %>
                      -
                    <% end %>
                  </td>
                  <td><%= currency(dp.w1) %></td>
                  <td>
                    <% if diff_12 < 0 %>
                      <span class="text-danger"><i class="fa fa-caret-down"></i> <%= currency(diff_12) %></span>
                    <% elsif diff_12 > 0 %>
                      <span class="text-success"><i class="fa fa-caret-up"></i> +<%= currency(diff_12) %></span>
                    <% else %>
                      -
                    <% end %>
                  </td>
                </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
```

- [ ] **Step 2: Run verification script for ERB compilation and output**

Run: `/usr/share/rvm/bin/rvm 2.5.8 do bundle exec rails runner "file = File.read('app/views/penjualan/template_dashboard/customer_decrease.html.erb'); puts ERB.new(file).src.class.to_s"`
Expected: String (Clean ERB compilation).

- [ ] **Step 3: Commit changes**

```bash
git add app/views/penjualan/template_dashboard/customer_decrease.html.erb
git commit -m "feat(view): add weekly change diff columns with indicators to customer_decrease view"
```
