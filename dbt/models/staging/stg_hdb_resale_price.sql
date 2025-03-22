{{
    config(
        materialized='view'
    )
}}

select
    -- year and month
    month as year_month,
    extract(year from month) as year,
    extract(month from month) as month,

    -- flat info
    town,
    flat_type,
    block,
    street_name,
    storey_range,
    cast(left(storey_range,2) as int64) as min_storey,
    cast(right(storey_range,2) as int64) as max_storey,
    cast(floor_area_sqm as numeric) as floor_area_sqm,
    flat_model,
    cast(lease_commence_date as int64) as lease_commence_date,
    remaining_lease,

    -- transaction info
    cast(resale_price as int64) as resale_price

from {{ source('staging', 'hdb_resale_price') }}
where month >= DATE('1990-01-01') and month <= CURRENT_DATE
