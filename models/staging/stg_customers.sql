with

source as (

    select * from {{ source('ecom', 'raw_customers') }} where _fivetran_deleted = false

),

renamed as (

    select

        ----------  ids
        id as customer_id,

        ---------- text
        name as customer_name

    from source

)

select * from renamed
