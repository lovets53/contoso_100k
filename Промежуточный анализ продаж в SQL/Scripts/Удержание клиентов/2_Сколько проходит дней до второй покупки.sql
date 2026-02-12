--title:Среднее время второй покупки в каждой когорте
WITH purchase_gaps AS (
    SELECT 
        customerkey,
        orderdate,
        cohort_year,
        ROW_number() over(PARTITION BY customerkey ORDER BY orderdate) AS number_purchase,
        LAG(orderdate) OVER (PARTITION BY customerkey ORDER BY orderdate) AS prev_orderdate,
        (orderdate - LAG(orderdate) OVER (PARTITION BY customerkey ORDER BY orderdate)) AS days_between_orders
    FROM cogort_analysis 
)
SELECT
	cohort_year,
	round(avg(days_between_orders)) AS avg_count_day_until_the_second_purchase,
	count(*) AS count_purchase
FROM purchase_gaps
WHERE number_purchase = 2
GROUP BY cohort_year