# -*- coding: utf-8 -*-
# vim: ft=sls

{%- if grains.os_family|lower == 'redhat' %}
    {%- set tplroot = tpldir.split('/')[0] %}
    {%- from tplroot ~ "/libs/map.jinja" import prometheus as p with context %}

    {%- if p.pkg.use_upstream_repo and 'repo' in p.pkg and p.pkg.repo %}

prometheus-package-repo-clean-pkgrepo-managed:
  pkgrepo.absent:
    - name: {{ p.pkg['repo']['name'] }}

    {%- endif %}
{%- endif %}
