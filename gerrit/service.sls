# -*- coding: utf-8 -*-
# vim: ft=yaml

{% from "gerrit/map.jinja" import settings with context -%}

gerrit_service:
  service.running:
    - name: {{ settings.service }}
    - enable: true
