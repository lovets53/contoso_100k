
WITH cogort AS (
	SELECT distinct
		customerkey,
		orderdate,
		orderkey,
		min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
		EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
	FROM sales
	ORDER BY customerkey
),
num_purchase AS (
	SELECT 
		customerkey,
		orderdate,
		cohort_year,
		ROW_number() over(PARTITION BY customerkey ORDER BY orderdate) AS number_purchase
	FROM cogort
),
count_purchase AS (
	SELECT 
		cohort_year,
		number_purchase,
		count(customerkey) AS count_purchase,
		round(100.0*count(customerkey)/max(count(customerkey)) OVER(PARTITION BY cohort_year),2) AS percentage_of_purchases
	FROM num_purchase
	GROUP BY cohort_year, number_purchase
	ORDER BY cohort_year, number_purchase
)
SELECT
	cohort_year,
	number_purchase,
	count_purchase,
	percentage_of_purchases
FROM count_purchase
WHERE percentage_of_purchases > 1 ;


