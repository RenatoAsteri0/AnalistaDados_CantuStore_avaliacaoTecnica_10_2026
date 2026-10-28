with source as (
    select
        hjmpTS as hjmpts,
        nullif(lower(trim(createdTS)), '') as createdts,
        nullif(lower(trim(modifiedTS)), '') as modifiedts,
        typepkstring,
        ownerpkstring,
        "PK" as pk,
        sealed,
        p_baseprice,
        p_calculated,
        p_entrynumber,
        p_product,
        p_quantity,
        p_totalprice,
        p_unit,
        p_giveaway,
        p_rejected,
        p_entrygroupnumbers,
        p_order
    from {{ raw_source('tb_cartentries/tb_cartentries.parquet', 'parquet') }}
),
checked as (
    select
        *,
        count(*) over (partition by pk) as pk_occurrences
    from source
)
select
    *,
    case when pk is not null then pk_occurrences > 1 else false end as is_duplicate_pk
from checked
