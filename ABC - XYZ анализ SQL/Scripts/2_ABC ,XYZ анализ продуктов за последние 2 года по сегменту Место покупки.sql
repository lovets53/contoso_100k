
--title: ABC - XYZ анализ продуктов за последние 2 года по сегменту Место покупки
WITH last_date AS ( 
-- ШАГ 1: Находим последнею дату в таблице
    SELECT max(orderdate) AS last_date_sales FROM sales
),
-- ШАГ 2: Собираем данные по выручке товаров
sales_data_ABC AS (
    SELECT 
        countryname AS place_sales, -- место покупки
        productkey, 
        round(sum((unitprice - unitcost)*quantity/exchangerate),2) AS Gross_Margin_USD_per_place -- маржинальная прибыль продукта по месту продажи
    FROM sales 
    LEFT JOIN store USING(storekey)
    CROSS JOIN last_date
    WHERE orderdate >= last_date_sales - INTERVAL '2 year' -- смотрим продажи только за последние 2 года доступных данных
    GROUP BY productkey, countryname
),
-- ШАГ 3: Рассчитываем накопительную долю
cumulative_ABC AS (
    SELECT 
        place_sales,
        productkey,
        Gross_Margin_USD_per_place,
        SUM(Gross_Margin_USD_per_place) OVER (PARTITION BY place_sales) AS total_Gross_Margin_USD_per_place,  -- Общая маржинальная прибыль по всем товарам
        SUM(Gross_Margin_USD_per_place) OVER (PARTITION BY place_sales ORDER BY Gross_Margin_USD_per_place DESC) AS running_Gross_Margin_USD_per_place, -- Накопительная маржинальная прибыль
        SUM(Gross_Margin_USD_per_place) OVER (PARTITION BY place_sales ORDER BY Gross_Margin_USD_per_place DESC) 
        / 
        SUM(Gross_Margin_USD_per_place) OVER (PARTITION BY place_sales) AS cumulative_ratio_per_place -- Накопительная доля
    FROM sales_data_ABC
),
-- ───────────────────────────────
-- ШАГ 4: ЛОКАЛЬНЫЙ XYZ (по месту)
-- ───────────────────────────────
sales_data_XYZ_place AS (
    SELECT
        countryname AS place_sales, -- место покупки
        productkey,
        DATE_TRUNC('month', orderdate) AS month,
        sum(quantity) AS monthly_qty -- количество проданного товара в месяц
    FROM sales 
    LEFT JOIN store  USING(storekey)
    CROSS JOIN last_date 
    WHERE orderdate >= last_date_sales - INTERVAL '2 year' -- смотрим продажи только за последние 2 года доступных данных
    GROUP BY countryname, productkey, DATE_TRUNC('month', orderdate)
),
-- ШАГ 5: Считаем нужную статистику
sales_data_XYZ_place_stats AS (
    SELECT 
        place_sales,
        productkey,
        round(avg(monthly_qty), 2) AS avg_qty_place, -- среднее количество проданого товара
        stddev(monthly_qty) AS std_qty_place, 
        count(distinct month) AS months_place -- в скольких месяцах были продажи
    FROM sales_data_XYZ_place
    GROUP BY place_sales, productkey
    HAVING count(distinct month) >= 4
),
-- ──────────────────────────
-- ШАГ 6: ГЛОБАЛЬНЫЙ XYZ (без сегмента) 
-- ─────────────────────────
sales_data_XYZ_global_monthly AS (
	SELECT
		productkey,
		DATE_TRUNC('month', orderdate) as month,
		sum(quantity) AS monthly_quantity
	FROM sales 
	CROSS JOIN last_date
	WHERE orderdate >= last_date_sales - INTERVAL '2 year'
	GROUP BY productkey, DATE_TRUNC('month', orderdate)
),
-- ШАГ 7: Считаем нужную статистику
sales_data_XYZ_global_stats AS (
	SELECT 
		productkey,
		round(avg(monthly_quantity),2) AS avg_qty_global, -- среднее количество проданого товара
		STDDEV(monthly_quantity) as std_qty_global,
	    COUNT(DISTINCT month) as months_global -- в скольких месяцах были продажи
	FROM sales_data_XYZ_global_monthly
	group BY productkey
	HAVING COUNT(DISTINCT month) >= 4
),
-- Финальная сборка
classified AS (
    SELECT 
        a.place_sales,
        a.productkey,
        Gross_Margin_USD_per_place,
        Gross_Margin_USD_per_place / total_Gross_Margin_USD_per_place AS Gross_Margin_USD_percent_per_place,
        CASE 
            WHEN cumulative_ratio_per_place <= 0.8  THEN 'A'
            WHEN cumulative_ratio_per_place <= 0.95 THEN 'B'
            ELSE 'C'
        END AS abc_category,
        --XYZ-логика с приоритетом
       	COALESCE(avg_qty_place,avg_qty_global) AS avg_quantity, -- если в локальном расчете среднее колиство проданого товара 0, тогда выведет из глобально расчета
       	COALESCE(months_place ,months_global) AS months_count,
        CASE 
            WHEN l.productkey IS NOT NULL THEN 
                CASE 
                    WHEN std_qty_place / avg_qty_place <= 0.15 THEN 'X'
                    WHEN std_qty_place / avg_qty_place <= 0.3  THEN 'Y'
                    ELSE 'Z'
                END
            WHEN g.productkey IS NOT NULL THEN 
                CASE 
                    WHEN std_qty_global / avg_qty_global <= 0.15 THEN 'X'
                    WHEN std_qty_global / avg_qty_global <= 0.3  THEN 'Y'
                    ELSE 'Z'
                END
            ELSE 'ND'
        END AS xyz_score,
        -- Показываем откуда вывели результат
        CASE 
            WHEN l.productkey IS NOT NULL THEN 'place'
            WHEN g.productkey IS NOT NULL THEN 'global'
            ELSE 'no data'
        END AS xyz_class
    FROM cumulative_ABC a
    LEFT JOIN sales_data_XYZ_place_stats  l ON l.place_sales = a.place_sales AND l.productkey = a.productkey
    LEFT JOIN sales_data_XYZ_global_stats g ON g.productkey = a.productkey
)
SELECT
	place_sales,
	productname,
	categoryname,
	Gross_Margin_USD_per_place,
	Gross_Margin_USD_percent_per_place,
	avg_quantity,
	months_count,
	abc_category,
	xyz_score,
	xyz_class
FROM classified 
JOIN product USING(productkey);



