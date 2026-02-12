-- Нарастающий итог удержания
SELECT 
    cohort_year,
    ROUND(100.0 * COUNT(DISTINCT customerkey) FILTER (WHERE orderdate > first_purchase_date)/
    	COUNT(DISTINCT customerkey) FILTER (WHERE orderdate = first_purchase_date), 2) AS total_retention_rate,
    ROUND(100.0 * COUNT(DISTINCT customerkey) FILTER (WHERE orderdate > first_purchase_date AND orderdate <= first_purchase_date + INTERVAL '1 years')/
    	COUNT(DISTINCT customerkey) FILTER (WHERE orderdate = first_purchase_date), 2) AS retention_rate_1year,
    ROUND(100.0 * COUNT(DISTINCT customerkey) FILTER (WHERE orderdate > first_purchase_date AND orderdate <= first_purchase_date + INTERVAL '2 years')/
    	COUNT(DISTINCT customerkey) FILTER (WHERE orderdate = first_purchase_date), 2) AS retention_rate_2year,
    ROUND(100.0 * COUNT(DISTINCT customerkey) FILTER (WHERE orderdate > first_purchase_date AND orderdate <= first_purchase_date + INTERVAL '3 years')/
    	COUNT(DISTINCT customerkey) FILTER (WHERE orderdate = first_purchase_date), 2) AS retention_rate_3year,
    ROUND(100.0 * COUNT(DISTINCT customerkey) FILTER (WHERE orderdate > first_purchase_date AND orderdate <= first_purchase_date + INTERVAL '4 years')/
    	COUNT(DISTINCT customerkey) FILTER (WHERE orderdate = first_purchase_date), 2) AS retention_rate_4year
FROM cogort_analysis 
GROUP BY cohort_year
ORDER BY cohort_year;

