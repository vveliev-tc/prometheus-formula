# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/libs/map.jinja" import prometheus as p with context %}
{%- set name = 'node_exporter' %}

prometheus-exporters-clean-{{ name }}-textfile_collectors-smartmon:
  pkg.removed:
    - name: {{ p.exporters[name]['textfile_collectors']['smartmon']['pkg'] }}
  file.absent:
    - names:
      - {{ p.dir.archive ~ p.div ~ 'textfile_collectors' ~ p.div ~ 'smartmon.sh' }}
      - {{ p.pkg.component[name]['service']['args']['collector.textfile.directory'] }}{{ p.div }}smartmon.prom
  cron.absent:
    - identifier: prometheus-exporters-{{ name }}-textfile_collectors-smartmon-cronjob
