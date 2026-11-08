{% test country_code(model, column_name) %}

select {{ column_name }}
from {{ model }}
where {{ column_name }} is not null
    and ({{ dbt.length(column_name) }} <> 2 or upper({{ column_name }}) <> {{ column_name }})

{% endtest %}
