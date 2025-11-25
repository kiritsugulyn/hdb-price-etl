{% macro get_remaining_lease(remaining_lease, lease_commence_year, year) %}
    CASE
        WHEN regexp_like({{ remaining_lease }}, '^\d{2} year') THEN
            CAST(substr(regexp_extract({{ remaining_lease }}, '^\d{2}'), 1, 2) AS double)
            +
            CASE 
                WHEN regexp_like({{ remaining_lease }}, '\d{2} month') THEN
                    ROUND(CAST(substr(regexp_extract({{ remaining_lease }}, '\d{2}'), 1, 2) AS double) / 12, 1)
                ELSE 0
            END
        WHEN {{ remaining_lease }} = 'NaN' THEN
            {{ lease_commence_year }} + 99 - {{ year }}
        ELSE
            CAST({{ remaining_lease }} AS double)
    END
{% endmacro %}