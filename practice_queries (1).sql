-- MI Reporting practice queries (SQLite). Tables: finance_monthly, accounts, months, sales_volume_price
-- Sign convention: Revenue positive; costs are stored as positive numbers.

-- Q1. Total budget vs actual vs variance for the year, by category
SELECT a.category,
       ROUND(SUM(f.budget)) AS budget,
       ROUND(SUM(f.actual)) AS actual,
       ROUND(SUM(f.actual) - SUM(f.budget)) AS variance
FROM finance_monthly f
JOIN accounts a ON a.account_id = f.account_id
GROUP BY a.category;

-- Q2. Operating profit (Revenue - Cost of Sales - Opex) budget vs actual by business unit
SELECT f.business_unit,
       ROUND(SUM(CASE WHEN a.category='Revenue' THEN f.budget ELSE -f.budget END)) AS profit_budget,
       ROUND(SUM(CASE WHEN a.category='Revenue' THEN f.actual ELSE -f.actual END)) AS profit_actual
FROM finance_monthly f
JOIN accounts a ON a.account_id = f.account_id
GROUP BY f.business_unit;

-- Q3. Revenue variance % by quarter and business unit (which cells missed budget?)
SELECT m.quarter, f.business_unit,
       ROUND(100.0 * (SUM(f.actual) - SUM(f.budget)) / SUM(f.budget), 1) AS var_pct
FROM finance_monthly f
JOIN accounts a ON a.account_id = f.account_id
JOIN months m ON m.month = f.month
WHERE a.category = 'Revenue'
GROUP BY m.quarter, f.business_unit
ORDER BY var_pct;

-- Q4. Top 5 cost lines that overspent the most (actual - budget) for the year
SELECT f.business_unit, a.account_name,
       ROUND(SUM(f.actual) - SUM(f.budget)) AS overspend
FROM finance_monthly f
JOIN accounts a ON a.account_id = f.account_id
WHERE a.category <> 'Revenue'
GROUP BY f.business_unit, a.account_name
ORDER BY overspend DESC
LIMIT 5;

-- Q5. Months where total revenue actual was below budget
SELECT m.month_name,
       ROUND(SUM(f.budget)) AS budget, ROUND(SUM(f.actual)) AS actual
FROM finance_monthly f
JOIN accounts a ON a.account_id = f.account_id
JOIN months m ON m.month = f.month
WHERE a.category = 'Revenue'
GROUP BY m.month_no, m.month_name
HAVING SUM(f.actual) < SUM(f.budget)
ORDER BY m.month_no;

-- Q6. Month-on-month actual revenue and % change (window function: LAG)
WITH rev AS (
  SELECT m.month_no, m.month_name, SUM(f.actual) AS actual
  FROM finance_monthly f
  JOIN accounts a ON a.account_id = f.account_id
  JOIN months m ON m.month = f.month
  WHERE a.category = 'Revenue'
  GROUP BY m.month_no, m.month_name
)
SELECT month_name, ROUND(actual) AS actual,
       ROUND(100.0 * (actual - LAG(actual) OVER (ORDER BY month_no)) / LAG(actual) OVER (ORDER BY month_no), 1) AS mom_pct
FROM rev
ORDER BY month_no;

-- Q7. Year-to-date (running total) revenue actual vs budget (window function: SUM OVER)
WITH rev AS (
  SELECT m.month_no, m.month_name, SUM(f.budget) AS b, SUM(f.actual) AS a
  FROM finance_monthly f
  JOIN accounts x ON x.account_id = f.account_id
  JOIN months m ON m.month = f.month
  WHERE x.category = 'Revenue'
  GROUP BY m.month_no, m.month_name
)
SELECT month_name,
       ROUND(SUM(b) OVER (ORDER BY month_no)) AS ytd_budget,
       ROUND(SUM(a) OVER (ORDER BY month_no)) AS ytd_actual
FROM rev
ORDER BY month_no;

-- Q8. Price-volume variance on revenue by product (annual)
--   volume effect = (units_actual - units_budget) * price_budget
--   price effect  = (price_actual - price_budget) * units_actual
SELECT product,
       ROUND(SUM((units_actual - units_budget) * price_budget)) AS volume_effect,
       ROUND(SUM((price_actual - price_budget) * units_actual)) AS price_effect
FROM sales_volume_price
GROUP BY product;

-- Q9. Rank business units by Q3 marketing overspend % (CTE + RANK)
WITH q3 AS (
  SELECT f.business_unit,
         100.0 * (SUM(f.actual) - SUM(f.budget)) / SUM(f.budget) AS pct
  FROM finance_monthly f
  JOIN months m ON m.month = f.month
  WHERE f.account_id = 302 AND m.quarter = 'Q3'
  GROUP BY f.business_unit
)
SELECT business_unit, ROUND(pct, 1) AS overspend_pct,
       RANK() OVER (ORDER BY pct DESC) AS rnk
FROM q3;
