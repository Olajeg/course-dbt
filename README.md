
Template repository for the projects and environment of the course: Analytics engineering with dbt

> Please note that this sets some environment variables so if you create some new terminals please load them again.

# Analytics engineering with dbt

## Week 4 answers
**Snapshot**
The following products changed inventory: String of pearls, Monstera, Philodendron, Bamboo, Pothos, ZZ Plant.
For both String of pearls and Pothos we had a 0 inventory in the last week.

By far the greatest dropout occurs at the stage between page_view and add_to_cart, as can be seen by querying  the newly created fct_product_funnel model. 

## Week 3 answers
**Total conversion**
62.5%

```sql
WITH total_sessions AS (
    SELECT 
        product_id, 
        COUNT(DISTINCT session_id) AS session_count
    FROM 
        dbt_olajeg.int_events_with_products
    GROUP BY 
        product_id
),
total_checkouts AS (
    SELECT 
        product_id,
        COUNT(DISTINCT session_id) AS checkout_count
    FROM 
        dbt_olajeg.int_events_with_products
    WHERE 
        checkouts > 0
    GROUP BY 
        product_id
)
SELECT 
    ts.product_id,
    ts.session_count AS total_sessions,
    COALESCE(tc.checkout_count, 0) AS total_checkouts,
    CASE 
        WHEN ts.session_count > 0 THEN CAST(COALESCE(tc.checkout_count, 0) AS FLOAT) / ts.session_count
        ELSE 0 
    END AS conversion_ratio
FROM 
    total_sessions ts
LEFT JOIN 
    total_checkouts tc ON ts.product_id = tc.product_id
ORDER BY 
    ts.product_id;
```

**Conversion ratio by product**

```sql
WITH total_sessions AS (
    SELECT 
        product_id, 
        COUNT(DISTINCT session_id) AS session_count
    FROM 
        dbt_olajeg.int_events_with_products
    GROUP BY 
        product_id
),
total_checkouts AS (
    SELECT 
        product_id,
        COUNT(DISTINCT session_id) AS checkout_count
    FROM 
        dbt_olajeg.int_events_with_products
    WHERE 
        checkouts > 0
    GROUP BY 
        product_id
)
SELECT 
    ts.product_id,
    ts.session_count AS total_sessions,
    COALESCE(tc.checkout_count, 0) AS total_checkouts,
    CASE 
        WHEN ts.session_count > 0 THEN CAST(COALESCE(tc.checkout_count, 0) AS FLOAT) / ts.session_count
        ELSE 0 
    END AS conversion_ratio
FROM 
    total_sessions ts
LEFT JOIN 
    total_checkouts tc ON ts.product_id = tc.product_id
ORDER BY 
    ts.product_id;
```

**Snapshot: Products that changed from week 2 to 3**
Inventory of the following products changed:
String of pearls, Monstera, Philodendron, Bamboo, Pothos, ZZ Plant

```sql
WITH ranked_products AS (
    SELECT
        product_id,
        name,
        price,
        inventory,
        dbt_valid_from,
        dbt_valid_to,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY dbt_valid_from DESC) AS rn
    FROM
        dbt_olajeg.product_snapshot
    WHERE
        dbt_valid_to < '2024-04-01'
    OR 
        dbt_valid_to IS NULL 
),
changed_products_ranked AS 
(
SELECT
        product_id,
        name,
        price,
        inventory,
        dbt_valid_from,
        dbt_valid_to,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY dbt_valid_from DESC) AS rn
    FROM
        dbt_olajeg.product_snapshot
    WHERE
        dbt_valid_to >= '2024-04-01'
),
previous_versions AS (
    SELECT
        a.product_id,
        a.name AS current_product_name,
        b.name AS previous_product_name,
        a.price AS current_price,
        b.price AS previous_price,
        a.inventory AS current_inventory,
        b.inventory AS previous_inventory,
        a.dbt_valid_from AS current_valid_from,
        b.dbt_valid_from AS previous_valid_from,
        a.dbt_valid_to AS current_valid_to,
        b.dbt_valid_to AS previous_valid_to
    FROM
        changed_products_ranked a
    LEFT JOIN
        ranked_products b ON a.product_id = b.product_id
    WHERE 
        a.rn = 1 
    AND 
        b.rn = 1
)
SELECT
    *
FROM
    previous_versions
;
```


## Week 2 answers
**Users that bought more than once**
79.84%

```sql
SELECT 
    ROUND(
        (SELECT COUNT(*) FROM (SELECT user_id FROM dbt_olajeg.fct_order_users WHERE number_orders > 1 GROUP BY user_id) AS more_than_once)
        / CAST((SELECT COUNT(DISTINCT user_id) FROM dbt_olajeg.fct_order_users) AS FLOAT) 
        * 100, 
        2
    ) AS percentage_users_bought_more_than_once;
```

**Good indicators of repeating purchases**
* Frequent buyer and site visitor
* Using promotions
* High order values

**Likely not to purchase again**
* Not visited the site in a long time
* Only a single purchase at low price

**Additional data**
* More user specific information such as demographic data
* Public or commercial data to have benchmarks to measure our performance against

**Marts**
* Marketing mart
  * Focus on user-level
  * User characteristics in relation to orders
  * Promotion usage

* Product mart
  * Focus on product-level
  * User interaction on the site in relation to products 

**Tests**
I focus on the most basic tests on primary keys that have to be non-null and unique. 
Ideally one would only build tables that have passed the tests. If a large amount of bad data goes through to data users, I would ask them to disregard the most recent data update until the issue has been fixed. 


**Snapshot**
The following 4 products had a change in inventory: Pothos, Philodendron, Monstera, String of pearls


## Week 1 answers
Number of users
130
```sql
SELECT count(
  distinct user_guid)
FROM dev_db.dbt_olajeg.stg_postgres__users;
```

**Average orders per hour**
7.52
```sql
SELECT avg(order_number) as avg_orders_hour
FROM (
  SELECT 
    count(*) as order_number, 
    day(created_at) as order_day,
    hour(created_at) as order_hour
  FROM dev_db.dbt_olajeg.stg_postgres__orders
  GROUP BY order_day, order_hour
) as a
```

**Average order to delivery time**
3 days, 21 hours
```sql
with cte as 
(
SELECT 
    order_id, 
    DATEDIFF(hour, created_at, delivered_at) AS delivery_time
  FROM dev_db.dbt_olajeg.stg_postgres__orders
  WHERE status = 'delivered'
)
SELECT 
    AVG(delivery_time) AS average_delivery_time_hours,
    FLOOR(AVG(delivery_time) / 24) || ' days, ' || 
    MOD(AVG(delivery_time), 24) || ' hours' AS average_delivery_time_formatted
FROM cte
```

**Number of users by purchases**
| Number of Purchases | Number of Users |
|---------------------|-----------------|
| 1                   | 25              |
| 2                   | 28              |
| 3+                  | 71              |

```sql
with cte as 
(
SELECT 
count(order_id) as nr_orders, 
user_id
FROM dev_db.dbt_olajeg.stg_postgres__orders
GROUP BY user_id
),
cte_users AS (
  SELECT
    CASE 
      WHEN nr_orders >= 3 THEN '3 or more'
      ELSE CAST(nr_orders AS VARCHAR)
    END AS purchase_group,
    COUNT(*) AS num_users
  FROM cte
  GROUP BY purchase_group
)
SELECT purchase_group, 
num_users
FROM cte_users
ORDER BY purchase_group;
```

**Average unique sessions per users**
16.32
```sql
with cte as 
(
SELECT 
    count(distinct session_id) as sessions_per_hour,
    day(created_at) as session_day,
    hour(created_at) as session_hour
  From dev_db.dbt_olajeg.stg_postgres__events
  GROUP BY session_day, session_hour
)
SELECT 
  AVG(sessions_per_hour)
FROM cte;
```


## License
GPL-3.0
