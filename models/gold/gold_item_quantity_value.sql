-- Grao: mes, produto, unidade e moeda; somas nao misturam unidades/moedas.
select
    cast(date_trunc('month', try_cast(cart_entry_createdts as timestamp)) as date) as activity_month,
    product_id,
    unit_id,
    cart_currency_id,
    count(*) as cart_entry_rows,
    sum(quantity) as quantity_observed,
    sum(entry_total_price) as line_total_observed,
    count(*) filter (where quantity is null) as entries_without_quantity,
    count(*) filter (where entry_total_price is null) as entries_without_line_total
from {{ ref('obt_cartentries') }}
group by
    cast(date_trunc('month', try_cast(cart_entry_createdts as timestamp)) as date),
    product_id,
    unit_id,
    cart_currency_id
