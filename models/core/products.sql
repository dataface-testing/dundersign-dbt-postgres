-- Products, conformed across Salesforce and NetSuite. Investigated before
-- modeling: the single salesforce.product_2 row (a randomly-named CRM SKU)
-- and the single netsuite.item row ("Subscription Services", an
-- itemtype='Service' row) describe different real-world things -- a specific
-- sellable SKU on the CRM side vs. a generic revenue-recognition item
-- category on the GL side, with different names and different granularity.
-- There's no shared identity to collapse (contrast with vendors/gl_accounts,
-- where both systems demonstrably carry the same reference list), so this
-- unions with a source_system discriminator instead, same pattern as
-- gl_transactions.
with salesforce_product as (
    select
        product_2_id                            as id,
        'salesforce'                              as source_system,
        product_2_name                            as name,
        nullif(product_2_description, '')         as description,
        product_code,
        family                                     as product_family,
        is_active,
        cast(created_date as timestamp)            as created_at
    from {{ ref('stg_salesforce__product_2') }}
),
netsuite_item as (
    select
        item_id                                    as id,
        'netsuite'                                   as source_system,
        name,
        description,
        cast(null as {{ dbt.type_string() }})        as product_code,
        item_type                                    as product_family,
        cast(null as boolean)                        as is_active,
        cast(null as timestamp)                      as created_at
    from {{ ref('stg_netsuite__item') }}
)
select * from salesforce_product
union all
select * from netsuite_item
