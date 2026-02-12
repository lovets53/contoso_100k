/*Данная воронка может вводить в заблуждение: кажется, что в последние годы клиенты реже совершают повторные покупки.
* Но это не отражает реального положения дел - у более старых когорт (2015-2018) было значительно больше времени на совершение повторных покупок.
* Рекомендуется анализировать графики удержания клиентов в разрезе лет, где сравнение происходит на одинаковых временных интервалах. 
 */
--title: воронка продаж
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
		count(customerkey) AS count_purchase
	FROM num_purchase
	GROUP BY cohort_year, number_purchase
	ORDER BY cohort_year, number_purchase
)
SELECT
	cohort_year,
	number_purchase,
	count_purchase,
	round(100.0*count_purchase/max(count_purchase) OVER(PARTITION BY cohort_year),2) AS percentage_of_purchases
FROM count_purchase
WHERE number_purchase < 6 