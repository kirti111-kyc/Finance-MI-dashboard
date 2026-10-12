# Finance MI Reporting Dashboard (Power BI, DAX, SQL)

A 2-page Power BI dashboard that shows budget vs actual performance for a fictional fintech with three business units (Payments, Lending, Trading Platform) over FY2026. All data is synthetic (made up for practice).

## Business questions
1. Are we on plan? How far are revenue and operating profit from budget?
2. Which business unit is off plan?
3. Which cost lines overspent?
4. When revenue missed budget, was it a volume problem or a price problem?

## Page 1: Overview
- Cards: Revenue (actual), Revenue variance, Operating profit (actual), Operating profit variance
- Line chart: monthly revenue, actual vs budget
- Bar chart: operating profit variance by business unit
- Takeaway sentence for management

## Page 2: Drill-down
- Matrix: cost variance by cost line and business unit (red = overspent by more than 5%)
- Table: price-volume variance by product
- Commentary: what happened, why, and what to do next

## Key findings
- Revenue was £14.22M against a £14.32M budget: £101k (0.7%) below budget.
- Operating profit was £1.55M against £1.65M budget.
- Payments revenue missed budget by 11% in Q2, driven by lower Card Payments volumes (volume effect about -£148k).
- Lending marketing was about 35% over budget in Q3 (+£49k for the year).
- Trading Platform beat budget in Q4 (revenue +9%), driven by Equity Trades volume (about +£116k).

## Tools and skills used
- Power BI: data model with relationships, DAX measures, conditional formatting, custom theme
- DAX: Revenue Actual/Budget, Cost Actual/Budget, Operating Profit, Variance and Variance %, Volume Effect, Price Effect
- SQL (SQLite): practice queries to validate the dashboard numbers (joins, GROUP BY, CTE, window functions)

## Key DAX
```
Revenue Actual = CALCULATE(SUM(finance_monthly[actual]), accounts[category] = "Revenue")
Cost Actual = CALCULATE(SUM(finance_monthly[actual]), accounts[category] <> "Revenue")
Operating Profit Actual = [Revenue Actual] - [Cost Actual]
Cost Variance % = DIVIDE([Cost Variance], [Cost Budget])
Volume Effect = SUMX(sales_volume_price, (sales_volume_price[units_actual] - sales_volume_price[units_budget]) * sales_volume_price[price_budget])
Price Effect = SUMX(sales_volume_price, (sales_volume_price[price_actual] - sales_volume_price[price_budget]) * sales_volume_price[units_actual])
```

## Files
- `Finance_MI_Dashboard.pdf` - both dashboard pages
- `Finance_MI_Dashboard.pbix` - Power BI file (open with Power BI Desktop)
- `finance_monthly.csv`, `accounts.csv`, `months.csv`, `sales_volume_price.csv` - synthetic data
- `practice_queries.sql` - SQL queries used to validate the dashboard numbers
