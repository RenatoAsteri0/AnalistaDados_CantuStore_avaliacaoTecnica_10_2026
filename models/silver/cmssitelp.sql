with source as (
    select
        "ITEMPK" as itempk,
        nullif(lower(trim(p_name)), '') as p_name
    from {{ raw_source('tb_cmssitelp.csv', 'csv') }}
),
checked as (
    select
        *,
        count(*) over (partition by itempk) as itempk_occurrences
    from source
)
select
    *,
    case when itempk is not null then itempk_occurrences > 1 else false end as is_duplicate_itempk
from checked
