{{
    config(
        materialized='view'
    )
}}

select
    -- year and month
    extract(year from month) as year,
    extract(month from month) as month,

    -- flat info
    town,
    flat_type,
    block,
    street_name,
    storey_range,
    cast(floor_area_sqm as numeric) as floor_area_sqm,
    flat_model,
    cast(lease_commence_date as int64) as lease_commence_date,
    remaining_lease,

    -- transaction info
    cast(resale_price as int64) as resale_price

from {{ source('staging', 'hdb_resale_price') }}
where month >= DATE('1990-01-01') and month <= CURRENT_DATE


-- -- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
-- {% if var('is_test_run', default=true) %}

--   limit 100

-- {% endif %}