#!/usr/bin/env bash

get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value=$(tmux show-option -gqv "$option")
  echo "${option_value:-${default_value}}"
}

readonly key="$(get_tmux_option "@fpp-key" "f")"

readonly tmpfile="${TMPDIR:-/tmp}/tmux-buffer"

tmux bind-key "$key" capture-pane -J \\\; \
    save-buffer "${tmpfile}" \\\; \
    delete-buffer \\\; \
    new-window -n fpp -c "#{pane_current_path}" "cat '${tmpfile}' | fpp ; rm '${tmpfile}'"
