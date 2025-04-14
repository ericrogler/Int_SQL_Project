CREATE OR REPLACE
VIEW public.cohort_analysis AS
WITH customer_revenue AS (
SELECT
	s.customerkey,
	s.orderdate,
	sum(s.quantity::double PRECISION * s.netprice * s.exchangerate) AS total_net_revenue,
	count(s.orderkey) AS num_orders,
	MAX(c.countryfull) AS countryfull,
	MAX(c.age) AS age,
	MAX(c.givenname) AS givenname,
	MAX(c.surname) AS surname
FROM
	sales s
INNER JOIN customer c ON
	c.customerkey = s.customerkey
GROUP BY
	s.customerkey,
	s.orderdate
        )
 SELECT
	customerkey,
	orderdate,
	total_net_revenue,
	num_orders,
	countryfull,
	age,
	CONCAT(TRIM(givenname), ' ', TRIM(surname)) AS cleaned_name,
	min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
	EXTRACT(YEAR FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
FROM
	customer_revenue cr;