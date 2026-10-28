with source as (
    select
        hjmpTS as hjmpts,
        nullif(lower(trim(createdTS)), '') as createdts,
        nullif(lower(trim(modifiedTS)), '') as modifiedts,
        typepkstring,
        ownerpkstring,
        "PK" as pk,
        sealed,
        p_calculated,
        p_code,
        p_currency,
        p_deliveryaddress,
        p_deliverycost,
        p_deliverymode,
        p_deliverystatus,
        p_description,
        p_expirationtime,
        p_name,
        p_net,
        p_paymentaddress,
        p_paymentcost,
        p_paymentinfo,
        p_paymentmode,
        p_paymentstatus,
        p_status,
        p_exportstatus,
        p_statusinfo,
        p_totalprice,
        p_totaldiscounts,
        p_totaltax,
        p_user,
        p_subtotal,
        p_discountsincludedeliverycost,
        p_discountsincludepaymentcost,
        p_previousdeliverymode,
        p_site,
        p_store,
        nullif(lower(trim(p_guid)), '') as p_guid,
        p_deliveryinfo,
        p_subtotalservice,
        case
            when regexp_full_match(regexp_replace(trim(p_zipcodecalculatedelivery), '[.]0$', ''), '[0-9]{7}')
                then '0' || regexp_replace(trim(p_zipcodecalculatedelivery), '[.]0$', '')
            when regexp_full_match(regexp_replace(trim(p_zipcodecalculatedelivery), '[.]0$', ''), '[0-9]{8}')
                then regexp_replace(trim(p_zipcodecalculatedelivery), '[.]0$', '')
            else nullif(lower(trim(p_zipcodecalculatedelivery)), '')
        end as p_zipcodecalculatedelivery,
        p_subtotalwithoutdiscounts
    from {{ raw_source('tb_carts/tb_carts.parquet', 'parquet') }}
),
checked as (
    select
        *,
        case when pk is not null then count(*) over (partition by pk) end as source_pk_copies,
        row_number() over (partition by pk order by pk) as source_row_number
    from source
),
deduplicated as (
    select
        * exclude (source_row_number),
        case when pk is not null and source_pk_copies > 1 then true else false end as had_duplicate_pk
    from checked
    where pk is null or source_row_number = 1
)
select * from deduplicated
