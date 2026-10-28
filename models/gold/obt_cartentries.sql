-- Grao: uma linha por item de carrinho.
-- LEFT JOINs preservam itens sem correspondencia nas tabelas relacionadas.
select
    current_timestamp as obt_silver_processed_at,

    -- Item de carrinho
    e.pk as cart_entry_pk,
    e.p_order as cart_id_reference,
    e.createdts as cart_entry_createdts,
    e.modifiedts as cart_entry_modifiedts,
    e.p_entrynumber as entry_number,
    e.p_product as product_id,
    e.p_quantity as quantity,
    e.p_baseprice as base_price,
    e.p_totalprice as entry_total_price,
    e.p_unit as unit_id,
    e.p_giveaway as is_giveaway,
    e.p_rejected as is_rejected,
    e.pk_occurrences as cart_entry_pk_occurrences,
    e.is_duplicate_pk as cart_entry_had_duplicate_pk,

    -- Carrinho
    c.pk as cart_pk,
    c.createdts as cart_createdts,
    c.modifiedts as cart_modifiedts,
    c.p_code as cart_code,
    c.p_currency as cart_currency_id,
    c.p_user as user_id,
    c.p_deliveryaddress as delivery_address_id,
    c.p_paymentaddress as payment_address_id,
    c.p_paymentinfo as payment_info_id,
    c.p_paymentmode as payment_mode_id,
    c.p_site as site_id,
    c.p_status as cart_status,
    c.source_pk_copies as cart_source_pk_copies,
    c.had_duplicate_pk as cart_had_duplicate_pk,
    e.p_order is null as missing_cart_reference,
    e.p_order is not null and c.pk is null as unmatched_cart_reference,

    -- Usuario: atributos sem contato ou identificadores pessoais diretos
    u.pk as user_pk,
    u.createdts as user_createdts,
    u.p_type as user_type,
    u.p_logindisabled as user_login_disabled,
    u.p_subscribenewsletter as user_newsletter_opt_in,
    u.p_basestore as user_base_store_id,

    -- Forma de pagamento
    pm.pk as payment_mode_pk,
    pm.p_code as payment_mode_code,
    pm.p_active as payment_mode_active,
    pm.p_net as payment_mode_net,

    -- Informacao de pagamento
    pi.pk as payment_info_pk,
    pi.p_installments as payment_installments,

    -- Endereco de entrega e regiao
    da.pk as delivery_address_pk,
    da.p_country as delivery_country_id,
    da.p_region as delivery_region_id,
    da.p_town as delivery_town,
    da.p_district as delivery_district,
    dr.p_isocode as delivery_region_code,
    dr.p_isocodeshort as delivery_region_code_short,

    -- Endereco de pagamento e regiao
    pa.pk as payment_address_pk,
    pa.p_country as payment_country_id,
    pa.p_region as payment_region_id,
    pa.p_town as payment_town,
    pa.p_district as payment_district,
    pr.p_isocode as payment_region_code,
    pr.p_isocodeshort as payment_region_code_short

from {{ ref('cartentries') }} as e
left join {{ ref('carts') }} as c
    on e.p_order = c.pk
left join {{ ref('users') }} as u
    on c.p_user = u.pk
left join {{ ref('paymentmodels') }} as pm
    on c.p_paymentmode = pm.pk
left join {{ ref('paymentinfos') }} as pi
    on c.p_paymentinfo = pi.pk
left join {{ ref('addresses') }} as da
    on c.p_deliveryaddress = da.pk
left join {{ ref('regions') }} as dr
    on da.p_region = dr.pk
left join {{ ref('addresses') }} as pa
    on c.p_paymentaddress = pa.pk
left join {{ ref('regions') }} as pr
    on pa.p_region = pr.pk
