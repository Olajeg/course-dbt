with events as
(
    select * from {{ref('dim_events')}}
),

order_items as 
(
    select * from {{ref('dim_orderItems')}}
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
sum(page_views) as page_views,
sum(added_to_cart) as added_to_cart,
sum(checkouts) as checkouts,
sum(shippings) as shippings
from events 
left join order_items
on events.order_id = order_items.order_id
left join session_timing
on events.session_id = session_timing.session_id
group by 1,2,3,4,5,6
order by 1,4