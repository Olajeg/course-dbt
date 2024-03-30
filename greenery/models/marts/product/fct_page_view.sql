with events as
(
    select * from {{ref('stg_postgres__events')}}
),

order_items as 
(
    select * from {{ref('stg_postgres__order_items')}}
),

session_timing as 
(
    select * from {{ref('int_session_timings')}}
)

select events.session_id,
events.user_id,
order_items.product_id,
session_timing.session_started,
session_timing.session_ended,
datediff('minute', session_timing.session_started, session_timing.session_ended) as session_length_minute,
sum(case when events.event_type = 'page_view' then 1 else 0 end) as page_views,
sum(case when events.event_type = 'add_to_cart' then 1 else 0 end) as added_to_cart,
sum(case when events.event_type = 'checkout' then 1 else 0 end) as checkouts,
sum(case when events.event_type = 'package_shipped' then 1 else 0 end) as shippings
from events 
left join order_items
on events.order_id = order_items.order_id
left join session_timing
on events.session_id = session_timing.session_id
group by 1,2,3,4,5,6
order by 1,4