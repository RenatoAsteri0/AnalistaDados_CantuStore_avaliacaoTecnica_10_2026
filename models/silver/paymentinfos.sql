with source as (
    select
        nullif(lower(trim(createdTS)), '') as createdts,
        nullif(lower(trim(modifiedTS)), '') as modifiedts,
        "PK" as pk,
        p_installments
    from {{ raw_source('tb_paymentinfos/tb_paymentinfos.parquet', 'parquet') }}
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
