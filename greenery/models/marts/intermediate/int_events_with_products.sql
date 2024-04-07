SELECT 
  session_id,
  event_id,
  event_type,
  dim_events.order_id AS order_id_events,
  dim_events.product_id AS product_id_events,
  checkouts, 
  added_to_cart, 
  page_views, 
  CASE 
    WHEN dim_events.product_id IS NULL THEN dim_orderItems.product_id ELSE dim_events.product_id
  END AS product_id
FROM {{ref('dim_events')}} dim_events
LEFT JOIN {{ref('dim_orderItems')}} dim_orderItems
ON dim_events.order_id = dim_orderItems.order_id