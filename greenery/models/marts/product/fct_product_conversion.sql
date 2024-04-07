WITH total_sessions AS (
    SELECT 
        product_id, 
        COUNT(DISTINCT session_id) AS session_count
    FROM 
        {{ref('int_events_with_products')}}
    GROUP BY 
        product_id
),
total_checkouts AS (
    SELECT 
        product_id,
        COUNT(DISTINCT session_id) AS checkout_count
    FROM 
        {{ref('int_events_with_products')}}
    WHERE 
        checkouts > 0
    GROUP BY 
        product_id
)
SELECT 
    ts.product_id,
    ts.session_count AS total_sessions,
    COALESCE(tc.checkout_count, 0) AS total_checkouts,
    CASE 
        WHEN ts.session_count > 0 THEN CAST(COALESCE(tc.checkout_count, 0) AS FLOAT) / ts.session_count
        ELSE 0 
    END AS conversion_ratio
FROM 
    total_sessions ts
LEFT JOIN 
    total_checkouts tc ON ts.product_id = tc.product_id
ORDER BY 
    ts.product_id