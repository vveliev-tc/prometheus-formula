# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/libs/map.jinja" import prometheus as p with context %}
{%- from tplroot ~ "/libs/macros.jinja" import format_kwargs with context %}
{%- from tplroot ~ "/libs/libtofs.jinja" import files_switch with context %}
{%- set sls_archive_install = tplroot ~ '.archive.install' %}
{%- set sls_package_install = tplroot ~ '.package.install' %}

include:
  - {{ sls_archive_install if p.pkg.use_upstream_archive else sls_package_install }}

    {%- for name in p.wanted.clientlibs %}

prometheus-clientlibs-install-{{ name }}:
  file.directory:
    - name: {{ p.pkg.clientlibs[name]['path'] }}
    - makedirs: True
    - require_in:
      - archive: prometheus-clientlibs-install-{{ name }}
        {%- if grains.os|lower != 'windows' %}
    - user: {{ p.identity.rootuser }}
    - group: {{ p.identity.rootgroup }}
    - mode: '0755'
    - recurse:
        - user
        - group
        - mode
        {%- endif %}
        {%- if grains.get('osfinger', '') in ['Oracle Linux Server-8', 'Amazon Linux-2'] %}
  pkg.installed:
    - name: tar
    - require_in:
      - archive: prometheus-clientlibs-install-{{ name }}
        {%- endif %}
  archive.extracted:
    {{- format_kwargs(p.pkg.clientlibs[name]['archive']) }}
    - trim_output: true
    - enforce_toplevel: false
    - force: {{ p.force }}
    - options: --strip-components=1
    - retry: {{ p.retry_option|json }}
        {%- if grains.os|lower != 'windows' %}
    - user: {{ p.identity.rootuser }}
    - group: {{ p.identity.rootgroup }}
        {%- endif %}

    {%- endfor %}
