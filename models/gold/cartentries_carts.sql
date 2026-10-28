select
    cart_entry.*,
    cart.pk as matched_cart_pk,
    cart.p_user as cart_user_id,
    cart.createdts as cart_createdts,
    cart.p_paymentmode as cart_payment_mode_id,
    cart.p_site as cart_site_id,
    cart.source_pk_copies,
    cart.had_duplicate_pk,
    cart.pk is not null as has_cart_match,
    cart_entry.p_order is null as missing_cart_reference,
    cart_entry.p_order is not null and cart.pk is null as unmatched_cart_reference
from {{ ref('cartentries') }} as cart_entry
left join {{ ref('carts') }} as cart
    on cart_entry.p_order = cart.pk
