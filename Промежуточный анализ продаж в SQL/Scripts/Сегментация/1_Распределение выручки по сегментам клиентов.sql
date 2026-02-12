--title: Сегментация клиентов по уровню трат
WITH customer_ltv AS (
	SELECT 
		customerkey,
		sum(total_ner_revenue) AS total_ltv
	FROM cogort_analysis 
	GROUP BY customerkey 
),
percentile_total_ltv AS (
	SELECT 
		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS percentile25_total_ltv,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS percentile75_total_ltv
	FROM customer_ltv
)
SELECT 
	customerkey,
	total_ltv,
	CASE 
		WHEN total_ltv < percentile25_total_ltv THEN '1 - low_rank'
		WHEN total_ltv > percentile75_total_ltv THEN '3 - high_rank'
		ELSE '2 - medium_rank'
	END AS segmentation_customer
FROM customer_ltv,percentile_total_ltv;

--title: Доля сегмета от общего числа выручки
WITH customer_ltv AS (
	SELECT 
		customerkey,
		sum(total_ner_revenue) AS total_ltv
	FROM cogort_analysis 
	GROUP BY customerkey
),
percentile_total_ltv AS (
	SELECT 
		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS percentile25_total_ltv,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS percentile75_total_ltv
	FROM customer_ltv
),
total_ltv_segmentation AS (
SELECT 
	sum(total_ltv) AS total_ltv,
	CASE 
		WHEN total_ltv < percentile25_total_ltv THEN '1 - low_rank'
		WHEN total_ltv > percentile75_total_ltv THEN '3 - high_rank'
		ELSE '2 - medium_rank'
	END AS segmentation_customer
FROM customer_ltv,percentile_total_ltv
GROUP BY segmentation_customer
)
SELECT
	segmentation_customer,
	round(total_ltv) AS total_ltv,
	round(100.0*total_ltv/sum(total_ltv) over(),2) AS percentage_segment
FROM total_ltv_segmentation
ORDER BY percentage_segment DESC;


