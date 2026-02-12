--Зная, что 2022 год для всех прошлых когорт был пиковым на возврат клиентов. 
--Возникает вопрос, сколько из этих клиентов не совершали покупку с момента года входа.
--И второй вопрос, сколько клиентов каждой когорты покупали в предшествующие 2022 году и потом вернулись в 2022 году.

--title: Какую долю вернувшихся клиентов в 2022 году составляют клиенты которые не покупали с года входа
WITH customer_activity_2015 AS (
    SELECT
        customerkey,
        cohort_year,
        -- Покупал ли в 2022
        MAX(CASE WHEN EXTRACT(YEAR FROM orderdate) = 2022 THEN 1 ELSE 0 END) AS active_in_2022,
        -- Когда была последняя покупка до 2022
        MAX(CASE WHEN EXTRACT(YEAR FROM orderdate) < 2022 THEN EXTRACT(YEAR FROM orderdate) END) AS last_active_year_before_2022
    FROM cogort_analysis 
    WHERE cohort_year < 2022
    GROUP BY customerkey,cohort_year
),
first_purchase_customerkey AS (
	SELECT 
		cohort_year,
		count(DISTINCT customerkey) AS new_customers_count
	FROM cogort_analysis 
	WHERE orderdate = first_purchase_date 
	GROUP BY 
		cohort_year
	ORDER BY 
		cohort_year
)
SELECT 
	cohort_year,
    new_customers_count AS cohort_customers_count, -- количество уникальных клиентов когорты
    COUNT(*) AS returning_customers__count, -- количество клиентов когорты, которые не покупали с года своей когорты и купили в 2022 году
    round(100.0*COUNT(*)/new_customers_count,2) AS percentage_returning_customers
FROM customer_activity_2015
JOIN first_purchase_customerkey USING (cohort_year)
WHERE active_in_2022 = 1 AND cohort_year = last_active_year_before_2022
GROUP BY cohort_year,new_customers_count
ORDER BY cohort_year;

--title: В какой из годов совершалась последняя покупка клиента перед 2022 годом и какую долю от вернувшихся занимает каждый год.
WITH customer_activity_2015 AS (
    SELECT
        customerkey,
        cohort_year,
        -- Покупал ли в 2022
        MAX(CASE WHEN EXTRACT(YEAR FROM orderdate) = 2022 THEN 1 ELSE 0 END) AS active_in_2022,
        -- Когда была последняя покупка до 2022
        MAX(CASE WHEN EXTRACT(YEAR FROM orderdate) < 2022 THEN EXTRACT(YEAR FROM orderdate) END) AS last_active_year_before_2022
    FROM cogort_analysis 
    WHERE cohort_year < 2022
    GROUP BY customerkey,cohort_year
)
SELECT 
	cohort_year,
    last_active_year_before_2022,
    COUNT(*) AS customers_count, -- количество клиентов, которые совершили покупку в 2022 году
    round(100.0*COUNT(*)/sum(COUNT(*)) over(PARTITION BY cohort_year),2) AS percentage_returning_customers -- доля клиентов когорты совершившие покупку в 2022 году
FROM customer_activity_2015
WHERE active_in_2022 = 1  -- Те кто купили в 2022
GROUP BY last_active_year_before_2022, cohort_year
ORDER BY cohort_year,last_active_year_before_2022;

