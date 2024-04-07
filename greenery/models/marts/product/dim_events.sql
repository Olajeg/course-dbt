{% set event_type_state = dbt_utils.get_column_values(table=ref('stg_postgres__events'), column='event_type') %}

with cte as 
(
SELECT 
  event_id,
  session_id,
  event_type,
  order_id,
  user_id,
  created_at,
  product_id,
  {% for event_type in event_type_state %}
    case when event_type = '{{event_type}}' then 1 else 0 end as is_{{event_type}},
  {% endfor %}
FROM {{ref('stg_postgres__events')}}
)
select 
  event_id,
  session_id,
  event_type,
  order_id,
  user_id,
  created_at,
  product_id,
  IS_PAGE_VIEW AS page_views,
  IS_ADD_TO_CART AS added_to_cart,
  IS_CHECKOUT AS checkouts,
  IS_PACKAGE_SHIPPED AS shippings
  from cte 