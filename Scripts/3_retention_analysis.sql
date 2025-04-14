/*
Identify active vs churned customers.
- Whether OR NOT they've made a purchase WITHIN the LAST 6 months

Examples OF churn PERIODs across multiple industries:
- E-commerce IS 6-12 months
- SaaS IS 30-90 days since LAST login/payment
- Mobile Apps IS 7-30 days since LAST SESSION
- B2B Businesses IS 6-12 months since LAST TRANSACTION

Why? Helps track retention AND engagement.
- Identifies at-risk customers before churn
- Finds who to target for re-engagement
- Evaluates retention strategy effectiveness
- Insights into customer lifecycle 
*/

WITH customer_last_purchase AS (
	SELECT
		customerkey,
		cleaned_name,
		orderdate,
		ROW_NUMBER() OVER(PARTITION BY customerkey ORDER BY orderdate DESC) AS rn,
		first_purchase_date,
		cohort_year
	FROM
		cohort_analysis
), churned_customers AS (
	SELECT
		customerkey,
		cleaned_name,
		first_purchase_date,
		orderdate AS last_purchase_date,
		CASE
			WHEN orderdate < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months' THEN 'Churned'
			ELSE 'Active'
		END AS customer_status,
		cohort_year
	FROM customer_last_purchase 
	WHERE rn = 1 -- rn = 1 IS ALSO DISTINCT FILTER.
		-- Helps to remove bias on customers who recently became customers and cannot be considered churned.	
		AND first_purchase_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months'
)
SELECT
	cohort_year,
	customer_status,
	COUNT(customerkey) AS num_customers,
	SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year) AS total_customers,
	100 * ROUND(COUNT(customerkey) / SUM(COUNT(customerkey)) OVER(PARTITION BY cohort_year), 3) AS status_percentage
FROM churned_customers
GROUP BY cohort_year, customer_status 