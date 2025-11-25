{% macro get_region(town) %}
    CASE lower({{ town }})
        WHEN 'sembawang' THEN 'North'
        WHEN 'woodlands' THEN 'North'
        WHEN 'yishun' THEN 'North'

        WHEN 'ang mo kio' THEN 'North-East'
        WHEN 'hougang' THEN 'North-East'
        WHEN 'punggol' THEN 'North-East'
        WHEN 'sengkang' THEN 'North-East'
        WHEN 'serangoon' THEN 'North-East'

        WHEN 'bedok' THEN 'East'
        WHEN 'pasir ris' THEN 'East'
        WHEN 'tampines' THEN 'East'

        WHEN 'bukit batok' THEN 'West'
        WHEN 'bukit panjang' THEN 'West'
        WHEN 'choa chu kang' THEN 'West'
        WHEN 'clementi' THEN 'West'
        WHEN 'jurong east' THEN 'West'
        WHEN 'jurong west' THEN 'West'
        WHEN 'tengah' THEN 'West'

        WHEN 'bishan' THEN 'Central'
        WHEN 'bukit merah' THEN 'Central'
        WHEN 'bukit timah' THEN 'Central'
        WHEN 'central area' THEN 'Central'
        WHEN 'geylang' THEN 'Central'
        WHEN 'kallang/whampoa' THEN 'Central'
        WHEN 'marine parade' THEN 'Central'
        WHEN 'queenstown' THEN 'Central'
        WHEN 'toa payoh' THEN 'Central'

        ELSE 'NA'
    END

{% endmacro %}