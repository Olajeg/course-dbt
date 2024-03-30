
SELECT 
  event_id,
  session_id,
  event_type,
  order_id,
  created_at,
  product_id,
  case when event_type = 'page_view' then 1 else 0 end as page_views,
case when event_type = 'add_to_cart' then 1 else 0 end as added_to_cart,
case when event_type = 'checkout' then 1 else 0 end as checkouts,
case when event_type = 'package_shipped' then 1 else 0 end as shippings
FROM {{ref('stg_postgres__events')}}