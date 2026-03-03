WITH cte AS (
SELECT 
	cohort_year,
	extract(YEAR FROM orderdate) AS year_purchase,
	count(DISTINCT customerkey) AS unique_customers_count
FROM cogort_analysis 
GROUP BY 
	year_purchase,
	cohort_year
ORDER BY 
	cohort_year,
	year_purchase
)
SELECT 
	year_purchase,
	SUM(unique_customers_count) AS total_customers,
	SUM(unique_customers_count) FILTER(WHERE cohort_year = year_purchase) AS new_customers,
	SUM(unique_customers_count) FILTER(WHERE cohort_year < year_purchase) AS returning_customers,
	round(100.0*SUM(unique_customers_count) FILTER(WHERE cohort_year < year_purchase)/SUM(unique_customers_count),2) AS returning_percentage
FROM cte
GROUP BY 
	year_purchase
ORDER BY 
	year_purchase;