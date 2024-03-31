
Template repository for the projects and environment of the course: Analytics engineering with dbt

> Please note that this sets some environment variables so if you create some new terminals please load them again.

# Analytics engineering with dbt

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
