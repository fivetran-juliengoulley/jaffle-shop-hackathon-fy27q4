{{ config(
    adapter = 'lakecompute'
) }}

with source as (


    select
        "id",
        "order_total",
        "ordered_at"

    from {{ source('ecom', 'raw_orders') }}



),

renamed as (

    select
        cast("id" as integer) as sale_id,
        "ordered_at" as sale_date,
        cast("order_total" as numeric(18, 2)) as sale_amount

    from source

)

select * from renamed
