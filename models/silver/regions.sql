with source as (
    select
        "hjmpTS" as hjmpts,
        createdTS as createdts,
        modifiedTS as modifiedts,
        "TypePkString" as typepkstring,
        "OwnerPkString" as ownerpkstring,
        "PK" as pk,
        nullif(lower(trim(sealed)), '') as sealed,
        "p_active" as p_active,
        nullif(lower(trim(p_isocode)), '') as p_isocode,
        "p_country" as p_country,
        nullif(lower(trim(p_isocodeshort)), '') as p_isocodeshort,
        "aCLTS" as aclts,
        "propTS" as propts
    from {{ raw_source('tb_regions.csv', 'csv') }}
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
