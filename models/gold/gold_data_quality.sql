-- Tabela longa: uma linha por verificacao e a quantidade afetada.
with obt as (
    select * from {{ ref('obt_cartentries') }}
),
distinct_carts as (
    select distinct cart_pk, cart_source_pk_copies, cart_had_duplicate_pk
    from obt
    where cart_pk is not null
)
select
    'items_missing_cart_reference' as quality_check,
    count(*) as affected_count,
    'cart_entry_rows' as count_unit,
    'p_order esta nulo no item.' as definition
from obt
where missing_cart_reference

union all

select
    'items_with_unmatched_cart_reference',
    count(*),
    'cart_entry_rows',
    'p_order esta preenchido, mas nao encontrou PK em carts.'
from obt
where unmatched_cart_reference

union all

select
    'items_without_product_id',
    count(*),
    'cart_entry_rows',
    'p_product esta nulo.'
from obt
where product_id is null

union all

select
    'items_without_valid_created_at',
    count(*),
    'cart_entry_rows',
    'A data de criacao do item esta nula ou nao pode ser convertida para timestamp.'
from obt
where try_cast(cart_entry_createdts as timestamp) is null

union all

select
    'items_without_unit_id',
    count(*),
    'cart_entry_rows',
    'p_unit esta nulo; nao e possivel interpretar a unidade da quantidade.'
from obt
where unit_id is null

union all

select
    'carts_with_duplicate_source_pk',
    count(*),
    'carts',
    'Carrinhos cuja PK aparecia mais de uma vez na origem antes da deduplicacao.'
from distinct_carts
where cart_had_duplicate_pk

union all

select
    'extra_source_rows_from_duplicate_cart_pks',
    coalesce(sum(cart_source_pk_copies - 1), 0),
    'source_rows',
    'Linhas excedentes removidas ao manter uma linha por PK de carrinho.'
from distinct_carts
where cart_had_duplicate_pk
