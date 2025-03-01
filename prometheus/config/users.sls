# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/libs/map.jinja" import mapdata as p with context %}

  {%- for name in p.wanted.component %}

prometheus-config-users-install-{{ name }}-group-present:
  group.present:
    - name: {{ name }}
    - system: true
    - require_in:
      - user: prometheus-config-users-install-{{ name }}-user-present

prometheus-config-users-install-{{ name }}-user-present:
  user.present:
    - name: {{ name }}
    - groups:
      - {{ name }}
              {%- if grains.os != 'Windows' %}
    - shell: {{ p.shell }}
                  {%- if grains.kernel|lower == 'linux' %}
    - createhome: false
    - system: true
                  {%- elif grains.os_family == 'MacOS' %}
    - unless: /usr/bin/dscl . list /Users | grep {{ name }} >/dev/null 2>&1
                  {%- endif %}
              {%- endif %}

  {%- endfor %}
