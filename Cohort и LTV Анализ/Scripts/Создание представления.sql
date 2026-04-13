CREATE OR REPLACE VIEW public.cogort_analysis
AS WITH customer_revenue AS (
         SELECT 
         	s.customerkey,
            s.orderdate,
            sum(1.0*s.quantity * s.netprice / s.exchangerate) AS total_ner_revenue,
            sum(1.0*s.quantity * s.netprice / s.exchangerate) - sum(1.0*s.quantity * s.unitcost/ s.exchangerate) AS marginal_profit,
            count(s.productkey) AS count_product,
            sum(s.quantity) AS quantity,
            c.countryfull,
            c.age,
            c.givenname,
            c.surname
           FROM sales s
             LEFT JOIN customer c ON c.customerkey = s.customerkey
          GROUP BY s.customerkey, s.orderdate, c.countryfull, c.age, c.givenname, c.surname
        )
 SELECT customerkey,
    orderdate,
    round(total_ner_revenue,2) AS total_ner_revenue,
    round(marginal_profit,2) AS marginal_profit,
    count_product,
    quantity,
    countryfull,
    age,
    givenname,
    surname,
    min(orderdate) OVER (PARTITION BY customerkey) AS first_purchase_date,
    EXTRACT(year FROM min(orderdate) OVER (PARTITION BY customerkey)) AS cohort_year
   FROM customer_revenue;