#! /bin/sh

# gerrit {{ service_name }}
# Maintainer: @tim
# Authors: @tim

# PROVIDE: {{ service_name }}
# REQUIRE: LOGIN
# KEYWORD: shutdown

. /etc/rc.subr

name="{{ service_name }}"
rcvar="{{ service_name }}_enable"
extra_commands="status"

load_rc_config {{ service_name }}
: ${{ '{' }}{{ service_name }}_enable:="NO"}

required_dirs="{{ directory }}"

start_cmd="start_gerrit"
stop_cmd="stop_gerrit"
restart_cmd="restart_gerrit"
status_cmd="print_status"

# Script variable names should be lower-case not to conflict with
# internal /bin/sh variables such as PATH, EDITOR or SHELL.
script="{{ directory }}/bin/gerrit.sh"

gerrit_execute(){
# Switch to the Gerrit user if it's not who is running the script.
if [ "$USER" != "{{ user }}" ]; then
  su {{ user }} -c "$script $1 -d {{ directory }}"
else
  eval "$script $1 -d {{ directory }}"
fi
}

start_gerrit() {
  gerrit_execute start
}

stop_gerrit() {
  gerrit_execute stop
}

print_status() {
  gerrit_execute status
}

restart_gerrit(){
  gerrit_execute restart
}

PATH="${PATH}:/usr/local/bin"
run_rc_command "$1"
