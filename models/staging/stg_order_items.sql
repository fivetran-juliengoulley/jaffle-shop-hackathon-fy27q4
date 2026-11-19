with

source as (

    select * from {{ source('ecom', 'raw_items') }} where _fivetran_deleted = false

),

renamed as (

    select

        ----------  ids
        id as order_item_id,
        order_id,
        sku as product_id

    from source

)

select * from renamed
