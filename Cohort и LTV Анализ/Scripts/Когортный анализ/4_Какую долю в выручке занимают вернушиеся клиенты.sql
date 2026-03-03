WITH cte AS (
SELECT 
	cohort_year,
	extract(YEAR FROM orderdate) AS year_purchase,
	round(sum(total_ner_revenue),2) AS total_ner_revenue
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
	SUM(total_ner_revenue) AS total_ner_revenue,
	SUM(total_ner_revenue) FILTER(WHERE cohort_year = year_purchase) AS total_ner_revenue_new_customers,
	SUM(total_ner_revenue) FILTER(WHERE cohort_year < year_purchase) AS total_ner_revenue_returning_customers,
	round(100.0*SUM(total_ner_revenue) FILTER(WHERE cohort_year < year_purchase)/SUM(total_ner_revenue),2) AS returning_percentage
FROM cte
GROUP BY 
	year_purchase
ORDER BY 
	year_purchase;
