SELECT 
    order_id,
    user_id,
    address_id,
    created_at,
    order_cost,
    shipping_cost,
    order_total,
    tracking_id,
    shipping_service,
    estimated_delivery_at,
    delivered_at,
    status,
        CASE 
        WHEN promo_id IS NOT NULL THEN 1 ELSE 0
    END AS promotion_applied,
    promo_id
FROM {{ref('stg_postgres__orders')}}