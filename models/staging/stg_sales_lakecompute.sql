{{ config(
    adapter = 'lakecompute'
) }}

with source as (


    select
        "id",
        "order_total",
        "ordered_at"

    from {{ source('ecom_lake', 'raw_orders') }}
    where _fivetran_deleted = false



),

renamed as (

    select
        "id" as sale_id,
        "ordered_at" as sale_date,
        "order_total" as sale_amount

    from source

)

select * from renamed
