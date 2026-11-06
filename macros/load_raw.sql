{% macro load_raw() %}
  {% set tables = graph.sources.values() | selectattr('source_name', 'equalto', 'raw') | list %}
  {% do run_query('create schema if not exists raw') %}
  {% set statements = [] %}
  {% for t in tables %}
    {% set pattern = var('data_dir') ~ '/' ~ t.name ~ '*.csv' %}
    {% set reader %}
      select * exclude (filename), current_timestamp as _loaded_at,
             parse_filename(filename) as _source_file
      from read_csv(%FILES%, header = true, all_varchar = true, strict_mode = true,
                    filename = true, union_by_name = true)
    {% endset %}
    {% do run_query('create table if not exists raw.' ~ t.name ~ ' as '
                    ~ reader | replace('%FILES%', "'" ~ pattern ~ "'") ~ ' limit 0') %}
    {% set new_files %}
      select file from glob('{{ pattern }}')
      where parse_filename(file) not in (select _source_file from raw.{{ t.name }})
      order by file
    {% endset %}
    {% set files = run_query(new_files).columns[0].values() %}
    {% if files | length > 0 %}
      {% do statements.append('insert into raw.' ~ t.name ~ ' by name '
          ~ reader | replace('%FILES%', "['" ~ files | join("', '") ~ "']") ~ ';') %}
    {% endif %}
  {% endfor %}
  {% if statements | length > 0 %}
    {% do run_query('begin transaction; ' ~ statements | join(' ') ~ ' commit;') %}
  {% endif %}
{% endmacro %}
