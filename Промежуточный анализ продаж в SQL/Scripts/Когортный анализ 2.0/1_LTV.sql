--title:LTV на пользователя
WITH cte AS (
SELECT 
    cohort_year,
    count(distinct customerkey) AS count_customers,
    EXTRACT(YEAR FROM orderdate) - cohort_year AS lifetime_period,
    ROUND(SUM(total_ner_revenue),2) AS period_revenue
FROM cogort_analysis
GROUP BY 
    cohort_year,
    lifetime_period
)
SELECT 
    cohort_year,
    lifetime_period,
    round(SUM(period_revenue) OVER(PARTITION BY cohort_year ORDER BY lifetime_period) / max(count_customers) OVER(PARTITION BY cohort_year),2) AS ltv_per_users
FROM cte
ORDER BY 
    cohort_year,
    lifetime_period;


--title:Total LTV
WITH cte AS (
SELECT 
    cohort_year,
    EXTRACT(YEAR FROM orderdate) - cohort_year AS lifetime_period,
    ROUND(SUM(total_ner_revenue),2) AS period_revenue
FROM cogort_analysis
GROUP BY 
    cohort_year,
    lifetime_period
)
SELECT 
    cohort_year,
    lifetime_period,
    SUM(period_revenue) OVER(PARTITION BY cohort_year ORDER BY lifetime_period)  AS ltv_per_users
FROM cte
ORDER BY 
    cohort_year,
    lifetime_period;