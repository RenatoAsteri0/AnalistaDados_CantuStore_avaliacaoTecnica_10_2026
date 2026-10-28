with source as (
    select
        nullif(lower(trim(createdTS)), '') as createdts,
        nullif(lower(trim(modifiedTS)), '') as modifiedts,
        "PK" as pk,
        p_country,
        p_district,
        nullif(lower(trim(p_postalcode)), '') as p_postalcode,
        p_region,
        nullif(lower(trim(p_town)), '') as p_town,
        nullif(lower(trim(p_ibgecode)), '') as p_ibgecode,
        nullif(lower(trim(p_reference)), '') as p_reference
    from {{ raw_source('tb_addresses/tb_addresses.parquet', 'parquet') }}
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
