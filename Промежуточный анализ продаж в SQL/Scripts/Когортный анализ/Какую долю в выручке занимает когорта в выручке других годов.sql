--title:Какую долю в выручке занимает когорта в выручке других годов.
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
	cohort_year,
	year_purchase,
	total_ner_revenue,
	round(SUM(total_ner_revenue) OVER(PARTITION BY year_purchase),2) AS year_total_revenue,
	round((100.0*total_ner_revenue/sum(total_ner_revenue) over(PARTITION BY year_purchase)),2) AS first_order_cohort_percentage
FROM cte
ORDER BY 
	cohort_year,
	year_purchase;
