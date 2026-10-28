WITH silver AS (
    SELECT
        count(*) AS silver_rows,
        count(DISTINCT pk) AS silver_distinct_item_pks,
        count(*) FILTER (WHERE pk IS NULL) AS silver_null_item_pks
    FROM main.cartentries
),
gold AS (
    SELECT
        count(*) AS gold_rows,
        count(DISTINCT cart_entry_pk) AS gold_distinct_item_pks,
        count(*) FILTER (WHERE cart_entry_pk IS NULL) AS gold_null_item_pks,
        count(*) FILTER (WHERE missing_cart_reference) AS missing_cart_reference_rows,
        count(*) FILTER (WHERE unmatched_cart_reference) AS unmatched_cart_reference_rows
    FROM main.obt_cartentries
)
SELECT
    silver_rows,
    gold_rows,
    gold_rows - silver_rows AS row_difference,
    silver_distinct_item_pks,
    gold_distinct_item_pks,
    silver_null_item_pks,
    gold_null_item_pks,
    missing_cart_reference_rows,
    unmatched_cart_reference_rows,
    CASE
        WHEN silver_rows = gold_rows
         AND silver_rows = silver_distinct_item_pks
         AND gold_rows = gold_distinct_item_pks
         AND silver_null_item_pks = 0
         AND gold_null_item_pks = 0
        THEN 'OK'
        ELSE 'REVISAR'
    END AS validation_status
FROM silver
CROSS JOIN gold;