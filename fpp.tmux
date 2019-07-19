#!/usr/bin/env bash

get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value=$(tmux show-option -gqv "$option")
  echo "${option_value:-${default_value}}"
}

readonly key="$(get_tmux_option "@fpp-key" "f")"

tmux bind-key "$key" capture-pane -J \\\; \
    save-buffer "${TMPDIR:-/tmp}/tmux-buffer" \\\; \
    delete-buffer \\\; \
    new-window -n fpp -c "#{pane_current_path}" "sh -c 'cat \"${TMPDIR:-/tmp}/tmux-buffer\" | fpp ; rm \"${TMPDIR:-/tmp}/tmux-buffer\"'"
