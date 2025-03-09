{% macro get_remaining_lease(remaining_lease, lease_commence_year, year) %}
    IF (
        REGEXP_CONTAINS({{remaining_lease}}, r'^\d{2} year'),
        CAST(LEFT(REGEXP_EXTRACT({{remaining_lease}}, r'^\d{2} year'),2) AS NUMERIC) + IF (
            REGEXP_CONTAINS({{remaining_lease}}, r'\d{2} month'),
            ROUND(CAST(LEFT(REGEXP_EXTRACT({{remaining_lease}}, r'\d{2} month'),2) AS NUMERIC) / 12, 1),
            0
        ),
        IF (
            {{remaining_lease}} = 'NaN',
            {{lease_commence_year}} + 99 - {{year}},
            CAST({{remaining_lease}} AS NUMERIC)
        )
    )

{% endmacro %}