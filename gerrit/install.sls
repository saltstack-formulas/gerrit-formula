# -*- coding: utf-8 -*-
# vim: ft=yaml

{% from "gerrit/map.jinja" import gerrit_settings with context -%}

{% set gerrit_war_file = "gerrit-" + gerrit_settings.install.version + ".war" -%}

java-installation:
  pkg.installed:
    - name: openjdk-7-jre

git-installation:
  pkg.installed:
    - name: git

gerrit-user:
  user.present:
    - name: {{ gerrit_settings.user }}

gerrit-directory:
  file.directory:
    - name: {{ gerrit_settings.base_directory }}/{{ gerrit_settings.site_directory }}
    - user: {{ gerrit_settings.user }}
    - group: {{ gerrit_settings.group }}
    - makedirs: True

gerrit-download:
  cmd.run:
    - name: curl -O -s {{ gerrit_settings.install.base_url }}/{{ gerrit_war_file }}
    - user: {{ gerrit_settings.user }}
    - group: {{ gerrit_settings.group }}
    - cwd: {{ gerrit_settings.base_directory }}
    - unless: test -f {{ gerrit_settings.base_directory }}/{{ gerrit_war_file }}

gerrit-configfile:
  file.managed:
    - name: /etc/default/gerritcodereview
    - source: salt://gerrit/files/gerritcodereview.jinja
    - user: root
    - group: root
    - mode: 0755
    - template: jinja

gerrit-initfile:
  file.symlink:
    - name: /etc/init.d/{{ gerrit_settings.service.name }}
    - target: {{ gerrit_settings.base_directory }}/{{ gerrit_settings.site_directory }}/bin/gerrit.sh
    - user: root
    - group: root

gerrit-init:
  cmd.run:
    - name: java -jar {{ gerrit_war_file }} init --batch -d {{ gerrit_settings.base_directory }}/{{ gerrit_settings.site_directory }}
    - user: {{ gerrit_settings.user }}
    - group: {{ gerrit_settings.group }}
    - cwd: {{ gerrit_settings.base_directory }}
    - unless: test -d {{ gerrit_settings.base_directory }}/{{ gerrit_settings.site_directory }}/bin

gerrit-service:
  service.running:
    - name: {{ gerrit_settings.service.name }}
