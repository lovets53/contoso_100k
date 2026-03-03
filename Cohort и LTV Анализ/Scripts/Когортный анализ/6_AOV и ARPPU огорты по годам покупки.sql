--title:AOV и ARPPU огорты по годам покупки
WITH cte AS (
SELECT 
	cohort_year,
	extract(YEAR FROM orderdate) AS year_purchase,
	round(sum(total_ner_revenue),2) AS total_ner_revenue,
	count(DISTINCT customerkey) AS unique_customers_count,
	count(*) AS CNT
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
	round(total_ner_revenue / unique_customers_count,2) AS arppu,
	round(total_ner_revenue / CNT,2) AS aov
FROM cte
ORDER BY 
	cohort_year,
	year_purchase;
