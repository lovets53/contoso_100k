--title: ABC - XYZ анализ продуктов за последние 2 года без сегментов
WITH last_date AS (
	-- ШАГ 1: Находим последнею дату в таблице
	SELECT max(orderdate) AS last_date_sales FROM sales
),
sales_data_ABC AS (
    -- ШАГ 2: Собираем данные по выручке товаров за последние 2 года
    SELECT 
        productkey, 
        round(sum((unitprice - unitcost)*quantity/exchangerate),2) AS Gross_Margin_USD
    FROM sales
    CROSS JOIN last_date 
    WHERE orderdate >= last_date_sales - INTERVAL '2 year'
    GROUP BY 
        productkey
),
cumulative_calc_ABC AS (
    -- ШАГ 3: Рассчитываем накопительную долю
    SELECT 
        productkey,
        Gross_Margin_USD,
        SUM(Gross_Margin_USD) OVER () AS total_Gross_Margin_USD, -- Общая выручка по всем товарам
        SUM(Gross_Margin_USD) OVER (ORDER BY Gross_Margin_USD DESC) AS running_Gross_Margin_USD, -- Накопительная сумма 
        SUM(Gross_Margin_USD) OVER (ORDER BY Gross_Margin_USD DESC) / SUM(Gross_Margin_USD) OVER () AS cumulative_ratio -- Накопительная доля (кумулятивный процент)
    FROM sales_data_ABC
),
sales_data_XYZ AS (
	-- ШАГ 4: Собираем данные по количеству продаж по месяцам за последние 2 года
	SELECT
		productkey,
		DATE_TRUNC('month', orderdate) as month,
		sum(quantity) AS monthly_quantity
	FROM sales 
	CROSS JOIN last_date
	WHERE orderdate >= last_date_sales - INTERVAL '2 year'
	GROUP BY productkey, DATE_TRUNC('month', orderdate)
),
product_stats_XYZ AS (
	-- ШАГ 5: Считаем нужную статистику
	SELECT 
		productkey,
		round(avg(monthly_quantity),2) AS avg_quantity, -- среднее количество проданого товара
		STDDEV(monthly_quantity) as std_quantity,
	    COUNT(DISTINCT month) as months_count -- в скольких месяцах были продажи
	FROM sales_data_XYZ
	group BY productkey
	HAVING COUNT(DISTINCT month) >= 4
),
classified AS (
-- ШАГ 6: Классифицируем и выводим результат
SELECT 
	productkey,
	Gross_Margin_USD,
	Gross_Margin_USD / total_Gross_Margin_USD AS Gross_Margin_USD_percent, -- Доля в общей выручке (%)
	CASE 
		WHEN cumulative_ratio <= 0.8 THEN 'A'
	    WHEN cumulative_ratio <= 0.95 THEN 'B'
	    ELSE 'C'
	END AS abc_category,
	avg_quantity,
	months_count,
    CASE 
	    WHEN avg_quantity IS NULL THEN 'ND' -- Мало данных для xyz
        WHEN std_quantity / avg_quantity <= 0.15 THEN 'X'
        WHEN std_quantity / avg_quantity <= 0.3 THEN 'Y'
        ELSE 'Z'
    END as xyz_score
FROM cumulative_calc_ABC
LEFT JOIN product_stats_XYZ using(productkey)
)
SELECT
	productname,
	categoryname,
	Gross_Margin_USD,
	Gross_Margin_USD_percent,
	avg_quantity,
	months_count,
	abc_category,
	xyz_score
FROM classified
JOIN product USING(productkey);


