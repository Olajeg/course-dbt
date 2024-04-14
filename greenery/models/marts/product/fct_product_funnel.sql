SELECT 
  int_products.product_id AS product_id,
  dim_products.name AS name,
  dim_products.price AS price,
  count(distinct session_id) AS number_views,
  sum(added_to_cart)/count(distinct session_id) AS add_to_cart_rate,
  sum(added_to_cart) AS number_cart,
  sum(checkouts) /sum(added_to_cart) AS ratio_shipped_if_added,
  sum(checkouts) AS number_shipped,
  sum(checkouts) /count(distinct session_id) AS conversion_rate
FROM {{ref('int_events_with_products')}} int_products
LEFT JOIN  {{ref('dim_products')}} dim_products
ON int_products.product_id = dim_products.product_id
GROUP BY 1,2,3