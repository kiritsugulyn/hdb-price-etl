{{
    config(
        materialized='view'
    )
}}

select
    blk_no,
    street,
    cast(max_floor_lvl as int64) as max_floor_lvl,
    year_completed

from {{ source('staging', 'hdb_property_info') }}