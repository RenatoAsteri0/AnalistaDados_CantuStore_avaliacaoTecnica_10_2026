-- Grao: mes e produto; product_id nulo e acompanhado na tabela de qualidade.
with product_activity as (
    select
        cast(date_trunc('month', try_cast(cart_entry_createdts as timestamp)) as date) as activity_month,
        product_id,
        count(*) as cart_entry_rows,
        count(distinct cart_pk) as distinct_carts
    from {{ ref('obt_cartentries') }}
    where product_id is not null
    group by
        cast(date_trunc('month', try_cast(cart_entry_createdts as timestamp)) as date),
        product_id
)
select
    *,
    dense_rank() over (
        partition by activity_month
        order by cart_entry_rows desc
    ) as product_frequency_rank
from product_activity
