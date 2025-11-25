{{
    config(
        materialized='view'
    )
}}

select
    -- year and month
    date_parse(month, '%Y-%m') as year_month,
    year(date_parse(month, '%Y-%m')) as year_num,
    month(date_parse(month, '%Y-%m')) as month_num,

    -- flat info
    town,
    flat_type,
    block,
    street_name,
    storey_range,
    cast(substr(storey_range, 1, 2) as bigint) as min_storey,
    cast(substr(storey_range, length(storey_range)-1, 2) as bigint) as max_storey,
    cast(floor_area_sqm as double) as floor_area_sqm,
    flat_model,
    cast(lease_commence_date as bigint) as lease_commence_date,
    remaining_lease,

    -- transaction info
    cast(resale_price as bigint) as resale_price

from {{ source('staging', 'resale_price') }}
where date_parse(month, '%Y-%m') >= timestamp '1990-01-01' and date_parse(month, '%Y-%m') <= current_timestamp