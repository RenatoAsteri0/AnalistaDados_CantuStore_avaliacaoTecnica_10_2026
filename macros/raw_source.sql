{% macro raw_source(filename, format) %}
  {% set path = var('data_root') ~ '/' ~ filename %}
  {% if format == 'parquet' %}
    read_parquet('{{ path }}')
  {% else %}
    read_csv_auto('{{ path }}', header=true, sample_size=-1)
  {% endif %}
{% endmacro %}
