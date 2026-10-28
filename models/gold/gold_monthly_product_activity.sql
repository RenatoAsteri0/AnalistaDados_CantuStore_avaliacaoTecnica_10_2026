select
    cast(date_trunc('month', try_cast(createdts as timestamp)) as date) as activity_month,
    p_product as product_id,
    count(*) as cart_entry_rows,
    count(distinct p_order) as distinct_cart_references,
    count(*) filter (where p_product is null) as entries_without_product_id,
    count(*) filter (where try_cast(createdts as timestamp) is null) as entries_without_valid_created_at,
    count(*) filter (where not has_cart_match) as entries_without_matching_cart
from {{ ref('cartentries_carts') }}
group by
    cast(date_trunc('month', try_cast(createdts as timestamp)) as date),
    p_product
