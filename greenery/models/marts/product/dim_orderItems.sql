SELECT
  order_id,
  product_id,
  quantity
FROM {{ref('stg_postgres__order_items')}}
