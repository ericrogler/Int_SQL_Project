/*
Optimization TL;DR:
- Avoid SELECT *
- use LIMIT for large datasets
- use WHERE, not HAVING: Filter before aggregation.
- use query execution plans
- minimize GROUP BY USAGE
- reduce joins WHEN possible
- optimize ORDER BY: index columns for sorting.
- use proper DATA types (e.g. text or varchar, integer or float, etc.)
- use proper indexing
- use partitioning
*/

/*
- EXPLAIN: Goes before SELECT and explains execution plan
- EXPLAIN ANALYZE: Displays plan and execution time as well as how it scans. Before SELECT.
- EXPLAIN vs EXPLAIN ANALYZE: EXPLAIN takes up a lot less time and money to run.
*/

EXPLAIN ANALYZE
-- on DBeaver, highlight the query to analyze outside of "explain" and do Ctrl+Shift+E for execution plan.
SELECT
	customerkey,
	SUM(quantity * netprice * exchangerate) AS net_revenue
FROM
	sales
WHERE
	orderdate >= '2024-01-01'
GROUP BY
	customerkey