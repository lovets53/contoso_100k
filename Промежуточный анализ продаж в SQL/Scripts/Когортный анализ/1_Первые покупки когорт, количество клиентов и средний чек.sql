--title:Первые покупки: количество клиентов, выручка когорты и средний чек
SELECT 
	cohort_year,
	count(*) AS new_customers_count,
	round(sum(total_ner_revenue),2) AS total_ner_revenue,
	round(sum(total_ner_revenue)/count(*),2) AS AOV_first_purchase_customer
FROM cogort_analysis 
WHERE orderdate = first_purchase_date 
GROUP BY 
	cohort_year
ORDER BY 
	cohort_year;


