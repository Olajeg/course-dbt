with dim_order as 
(
    select * from {{ref('dim_orders')}}
),
dim_users as 
(
    select * from {{ref('dim_users')}}
)

SELECT 
  dim_users.user_id as user_id,
  dim_users.first_name as first_name,
  dim_users.last_name as last_name,
  dim_users.email as email, 
  dim_users.created_at as user_created, 
  max(dim_order.created_at) as last_order,
  count(dim_users.user_id) as number_orders,
  count(dim_order.promo_id) as number_promo_used
FROM dim_order
LEFT JOIN dim_users
ON dim_order.user_id = dim_users.user_id
GROUP BY 1,2,3,4,5