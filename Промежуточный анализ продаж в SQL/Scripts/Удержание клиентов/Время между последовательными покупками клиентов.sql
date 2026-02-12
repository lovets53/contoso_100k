--title:Время между последовательными покупками клиентов
WITH purchase_gaps AS (
    SELECT 
        customerkey,
        orderdate,
        LAG(orderdate) OVER (PARTITION BY customerkey ORDER BY orderdate) AS prev_orderdate,
        (orderdate - LAG(orderdate) OVER (PARTITION BY customerkey ORDER BY orderdate)) AS days_between_orders
    FROM cogort_analysis 
)
SELECT 
    CASE 
        WHEN days_between_orders <= 365 THEN 'до 1 года'
        WHEN days_between_orders BETWEEN 366 AND 730 THEN 'от 1 года до 2 лет'
        ELSE 'более 2 лет'
    END AS period,
    COUNT(*) AS count_purchase,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS share
FROM purchase_gaps
WHERE days_between_orders IS NOT NULL 
GROUP BY PERIOD
ORDER BY MIN(days_between_orders);

