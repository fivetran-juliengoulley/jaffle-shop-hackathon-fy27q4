{{ config(
    adapter='lakecompute'
) }}

with

source as (

    select
        "id",
        "sale_date",
        "amount",
        "_fivetran_deleted",
        "_fivetran_synced"

    from {{ source('oracle_hva_001_fivetran', 'jg_sales') }}

),

renamed as (

    select
        cast("id" as integer) as sale_id,
        "sale_date",
        cast("amount" as numeric(18, 2)) as sale_amount,
        "_fivetran_synced" as synced_at

    from source

    where not coalesce("_fivetran_deleted", false)

)

select * from renamed
