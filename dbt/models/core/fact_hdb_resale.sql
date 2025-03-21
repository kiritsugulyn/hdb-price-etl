{{
    config(
        materialized='table',
    )
}}

with hdb_resale_price as (
    select *
    from {{ ref('stg_hdb_resale_price') }}
),
hdb_property_info as (
    select *
    from {{ ref('stg_hdb_property_info') }}
)

select 
    -- transaction time info
    hdb_resale_price.year_month as year_month,
    hdb_resale_price.year as year,
    hdb_resale_price.month as month,

    -- location info
    {{ get_region('hdb_resale_price.town') }} as region,
    initcap(hdb_resale_price.town) as town,
    initcap(hdb_resale_price.street_name) as street,
    upper(hdb_resale_price.block) as block,
    concat('Blk ', upper(hdb_resale_price.block), ' ', initcap(hdb_resale_price.street_name)) as address,

    -- flat info
    initcap(replace(hdb_resale_price.flat_type, '-', ' ')) as flat_type,
    initcap(replace(hdb_resale_price.flat_model, '-', ' ')) as flat_model,
    hdb_resale_price.min_storey as min_floor,
    hdb_resale_price.max_storey as max_floor,
    hdb_property_info.max_floor_lvl as bld_floor,
    {{ get_floor_range('hdb_resale_price.min_storey', 'hdb_resale_price.max_storey', 'hdb_property_info.max_floor_lvl') }} as floor_range,
    hdb_resale_price.floor_area_sqm as floor_area_sqm,
    round(10.7639 * hdb_resale_price.floor_area_sqm, 1) as floor_area_sqf,
    
    -- completion and lease info
    hdb_property_info.year_completed as bld_complete_year,
    hdb_resale_price.lease_commence_date as lease_commence_year,
    {{ get_remaining_lease("hdb_resale_price.remaining_lease", "hdb_resale_price.lease_commence_date", "hdb_resale_price.year") }} as lease_remain_year,

    -- transaction info
    hdb_resale_price.resale_price as resale_price,
    round(hdb_resale_price.resale_price / hdb_resale_price.floor_area_sqm, 2) as resale_price_psm,
    round(hdb_resale_price.resale_price / hdb_resale_price.floor_area_sqm / 10.7639, 2) as resale_price_psf,

from hdb_resale_price
left join hdb_property_info on upper(hdb_resale_price.street_name) = upper(hdb_property_info.street) and upper(hdb_resale_price.block) = upper(hdb_property_info.blk_no)
