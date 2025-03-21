{% macro get_floor_range(min_floor, max_floor, bld_floor) %}
    IF (
        ({{ min_floor }} >= 7 and {{ min_floor }} > 0.65 * {{ bld_floor }}) or {{ min_floor }} >= 21,
        'High Floor',
        IF (
            {{ max_floor }} < 0.35 * {{ bld_floor }} or {{ max_floor }} <= 6,
            'Low Floor',
            'Mid Floor'
        )
    )
{% endmacro %}