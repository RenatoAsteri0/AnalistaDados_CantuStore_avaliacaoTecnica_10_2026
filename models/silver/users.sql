with source as (
    select
        "hjmpTS" as hjmpts,
        createdTS as createdts,
        modifiedTS as modifiedts,
        "TypePkString" as typepkstring,
        nullif(lower(trim("OwnerPkString")), '') as ownerpkstring,
        "PK" as pk,
        nullif(lower(trim(p_uid)), '') as p_uid,
        "p_sessionlanguage" as p_sessionlanguage,
        "p_sessioncurrency" as p_sessioncurrency,
        "p_logindisabled" as p_logindisabled,
        nullif(lower(trim(p_lastlogin)), '') as p_lastlogin,
        nullif(lower(trim(p_originaluid)), '') as p_originaluid,
        "p_type" as p_type,
        "p_emailpreference" as p_emailpreference,
        "p_smspreference" as p_smspreference,
        "p_basestore" as p_basestore,
        nullif(lower(trim(p_dddphone)), '') as p_dddphone,
        nullif(lower(trim(p_dddcellphone)), '') as p_dddcellphone,
        nullif(lower(trim(p_dddcellphoneaditional)), '') as p_dddcellphoneaditional,
        p_birthday,
        "p_subscribenewsletter" as p_subscribenewsletter,
        nullif(lower(trim(p_registerdatetime)), '') as p_registerdatetime,
        "p_sapconsumerid" as p_sapconsumerid,
        nullif(lower(trim(p_sapcontactid)), '') as p_sapcontactid,
        "p_sapisreplicated" as p_sapisreplicated
    from {{ raw_source('tb_users.csv', 'csv') }}
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
