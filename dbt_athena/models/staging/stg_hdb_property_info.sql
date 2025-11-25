{{
    config(
        materialized='view'
    )
}}

select
    blk_no,
    street,
    cast(max_floor_lvl as bigint) as max_floor_lvl,
    year_completed

from {{ source('staging', 'property_info') }}