select 
  session_id,
 min(created_at) as session_started,
 max(created_at) as session_ended
from {{ref('stg_postgres__events')}}
group by 1