with source as (
    select
        "hjmpTS" as hjmpts,
        createdTS as createdts,
        modifiedTS as modifiedts,
        "TypePkString" as typepkstring,
        nullif(lower(trim("OwnerPkString")), '') as ownerpkstring,
        "PK" as pk,
        nullif(lower(trim(sealed)), '') as sealed,
        "p_active" as p_active,
        nullif(lower(trim(p_code)), '') as p_code,
        "p_paymentinfotype" as p_paymentinfotype,
        "aCLTS" as aclts,
        "propTS" as propts,
        "p_net" as p_net,
        nullif(lower(trim(p_sapcode)), '') as p_sapcode,
        "p_b2bactive" as p_b2bactive,
        "p_showinstallmentspdp" as p_showinstallmentspdp
    from {{ raw_source('tb_paymentmodes.csv', 'csv') }}
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
