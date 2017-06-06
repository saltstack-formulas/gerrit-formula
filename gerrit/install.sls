# -*- coding: utf-8 -*-
# vim: ft=yaml

{% from "gerrit/map.jinja" import settings with context -%}
{% set gerrit_war_file = "gerrit-" ~ settings.package.version ~ ".war" -%}

install_jre:
  pkg.installed:
    - name: {{ settings.jre }}

install_git:
  pkg.installed:
    - name: git

gerrit_user:
  user.present:
    - name: {{ settings.user }}

gerrit_group:
  group.present:
    - name: {{ settings.group }}

create_etc_dir:
  file.directory:
    - name: {{ settings.base_directory }}/{{ settings.site_directory }}/etc
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - makedirs: true

create_lib_dir:
  file.directory:
    - name: {{ settings.base_directory }}/{{ settings.site_directory }}/lib
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - makedirs: true

{% for name, library in salt['pillar.get']('gerrit:libraries', {}).items() %}
install_{{ name }}_lib:
  file.managed:
    - name: {{ settings.base_directory }}/{{ settings.site_directory }}/lib/{{ name }}.jar
    - source: {{ library.source }}
{% if library.source_hash is defined %}
    - source_hash: {{ library.source_hash }}
{% endif %}
    - user: {{ settings.user }}
    - group: {{ settings.group }}
{% endfor %}

create_plugins_dir:
  file.directory:
    - name: {{ settings.base_directory }}/{{ settings.site_directory }}/plugins
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - makedirs: true

{% for name, plugin in salt['pillar.get']('gerrit:plugins', {}).items() %}
install_{{ name }}_plugin:
  file.managed:
    - name: {{ settings.base_directory }}/{{ settings.site_directory }}/plugins/{{ name }}.jar
    - source: {{ plugin.source }}
{% if plugin.source_hash is defined %}
    - source_hash: {{ plugin.source_hash }}
{% endif %}
    - user: {{ settings.user }}
    - group: {{ settings.group }}
{% endfor %}

gerrit_war:
  file.managed:
    - name: {{ settings.base_directory }}/{{ gerrit_war_file }}
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - source: {{ settings.package.base_url }}/{{ gerrit_war_file }}
    - skip_verify: true

gerrit_config:
  file.managed:
    - name: {{ settings.base_directory }}/{{ settings.site_directory }}/etc/gerrit.config
    - source: salt://gerrit/files/gerrit.config
    - template: jinja
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - makedirs: true
    - defaults:
        settings: {{ settings|json }}
        war_file: {{ gerrit_war_file }}

secure_config:
  file.managed:
    - name: {{ settings.base_directory }}/{{ settings.site_directory }}/etc/secure.config
    - source: salt://gerrit/files/secure.config
    - template: jinja
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - makedirs: true
    - defaults:
        secure: {{ settings.secure|json }}

{# On FreeBSD setting the site path is handled by the rc.d script,
   which allows us to skip writing to /etc
   (which shouldn't be used for installed applications). #}
{% if grains.os_family != 'FreeBSD' %}
/etc/default/gerritcodereview:
  file.managed:
    - contents: GERRIT_SITE={{ settings.base_directory }}/{{ settings.site_directory }}
    - user: root
    - group: root
    - mode: 0755
{% endif %}

gerrit_init:
  cmd.run:
    - name: |
{%- if settings.core_plugins is not none %}
    {% for plugin in settings.core_plugins %}
        java -jar {{ settings.base_directory }}/{{ gerrit_war_file }} init --batch --install-plugin {{ plugin }} -d {{ settings.base_directory }}/{{ settings.site_directory }}
    {%- endfor %}
{%- else %}
        java -jar {{ settings.base_directory }}/{{ gerrit_war_file }} init --batch -d {{ settings.base_directory }}/{{ settings.site_directory }}
{%- endif %}
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - cwd: {{ settings.base_directory }}
    - unless: test -d {{ settings.base_directory }}/{{ settings.site_directory }}/bin
{% if settings.secondary_index %}
secondary_index:
  cmd.wait:
    - name: |
        java -jar {{ settings.base_directory }}/{{ gerrit_war_file }} reindex -d {{ settings.base_directory }}/{{ settings.site_directory }}
    - user: {{ settings.user }}
    - group: {{ settings.group }}
    - cwd: {{ settings.base_directory }}
    - watch:
      - cmd: gerrit_init
{% endif %}

link_logs_to_var_log_gerrit:
  file.symlink:
    - name: /var/log/gerrit
    - target: {{ settings.base_directory }}/{{ settings.site_directory }}/logs

gerrit_init_script:
{% if grains.os_family == 'FreeBSD' %}
  file.managed:
    - name: /usr/local/etc/rc.d/{{ settings.service }}
    - source: salt://gerrit/files/freebsd-rc.sh
    - template: jinja
    - mode: 755
    - defaults:
        service_name: {{ settings.service }}
        directory: {{ settings.base_directory }}/{{ settings.site_directory }}
        user: {{ settings.user }}
{% elif grains.init == "systemd" %}
  file.managed:
    - name: /etc/systemd/system/{{ settings.service }}.service
    - source: salt://gerrit/files/gerrit.service
    - template: jinja
    - mode: 0644
    - defaults:
        service_name: {{ settings.service }}
        directory: {{ settings.base_directory }}/{{ settings.site_directory }}
        user: {{ settings.user }}
{% else %}
  file.symlink:
    - name: /etc/init.d/{{ settings.service }}
    - target: {{ settings.base_directory }}/{{ settings.site_directory }}/bin/gerrit.sh
    - user: root
    - group: root
{% endif %}
