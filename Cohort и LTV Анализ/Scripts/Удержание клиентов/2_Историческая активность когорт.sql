--title:Какую долю в количестве клиентов занимает когорта в количестве клиентов других годов.
WITH cte AS (
SELECT 
	cohort_year,
	extract(YEAR FROM orderdate) AS year_purchase,
	count(DISTINCT customerkey) AS unique_customers_count,
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
	unique_customers_count,
	SUM(unique_customers_count) OVER(PARTITION BY year_purchase) AS year_cnt_customer,
	round((100.0*unique_customers_count/sum(unique_customers_count) over(PARTITION BY year_purchase)),2) AS first_cnt_customer_cohort_percentage,
	total_ner_revenue,
	round(SUM(total_ner_revenue) OVER(PARTITION BY year_purchase),2) AS year_total_revenue,
	round((100.0*total_ner_revenue/sum(total_ner_revenue) over(PARTITION BY year_purchase)),2) AS cohort_percentage_in_year_purchase
FROM cte
ORDER BY 
	cohort_year,
	year_purchase;


