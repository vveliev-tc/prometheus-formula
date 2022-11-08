# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/libs/map.jinja" import prometheus as p with context %}
{%- from tplroot ~ "/libs/libtofs.jinja" import files_switch with context %}
{%- from tplroot ~ "/libs/macros.jinja" import concat_args %}
{%- set sls_archive_install = tplroot ~ '.archive.install' %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- set sls_service_running = tplroot ~ '.service.running' %}

include:
  - {{ sls_archive_install if p.pkg.use_upstream_archive else sls_package_install }}
  - {{ sls_service_running }}

    {%- for name in p.wanted.component %}
        {%- if 'environ' in p.pkg.component[name] and 'args' in p.pkg.component[name]['environ'] %}
            {%- set args = p.pkg.component[name]['environ']['args'] %}
            {%- set arg_name = p.pkg.component[name]['environ']['environ_arg_name'] %}
            {%- if 'environ_file' in p.pkg.component[name] and p.pkg.component[name]['environ_file'] %}

prometheus-config-install-{{ name }}-environ_file:
  file.managed:
    - name: {{ p.pkg.component[name]['environ_file'] }}
    - source: {{ files_switch(['environ.sh.jinja'],
                              lookup='prometheus-config-install-' ~ name ~ '-environ_file'
                 )
              }}
    - makedirs: True
    - template: jinja
                {%- if grains.os != 'Windows' %}
    - mode: 640
    - user: {{ p.identity.rootuser }}
    - group: {{ p.identity.rootgroup }}
                {%- endif %}
    - context:
        args: {{ concat_args(args) }}
        arg_name: {{ arg_name }}
    - watch_in:
      - service: prometheus-service-running-{{ name }}
    - require:
      - sls: {{ sls_archive_install if p.pkg.use_upstream_archive else sls_package_install }}

                {%- if grains.os_family == 'FreeBSD' %}

prometheus-config-environ-{{ name }}-all:
  sysrc.managed:
    - name: {{ name }}_environ
    # service prometheus restart tends to hang on FreeBSD
    # https://github.com/saltstack/salt/issues/44848#issuecomment-487016414
    - value: "{{ concat_args(p.pkg.component[name]['environ']) }} >/dev/null 2>&1"
    - watch_in:
      - service: prometheus-service-running-{{ name }}

                {%- endif %}
            {%- endif %}
        {%- endif %}
    {%- endfor %}
