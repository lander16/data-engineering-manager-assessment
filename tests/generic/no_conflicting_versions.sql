{% test no_conflicting_versions(model, version_at) %}

select id, _source_file, {{ version_at }} as version_at
from {{ model }} as t
group by all
having count(distinct md5(cast(t as varchar))) > 1

{% endtest %}
