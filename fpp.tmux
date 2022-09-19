#!/usr/bin/env bash
set -Eeu -o pipefail

# This tmux plugin respects the following options:
#   @fpp-bind on/off
#     - Whether to bind keys on initialization.
#     - Defaults to 'on'.
#   @fpp-key
#     - The tmux key to bind to launching FPP.
#     - Defaults to 'f'.
#   @fpp-mode edit/paste
#     - Whether to launch EDITOR after FPP, or paste the file list into the
#       invoking pane.
#     - Defaults to 'edit'.
#   @fpp-path
#     - Custom path to FPP.
#     - Default to 'fpp'.
#
# This script has several entry points. With no arguments, it defaults to 'init'.
# The entrypoints are defined by functions prefixed with `tmux_fpp_…`:
#   init
#     - Sets default key bindings, according to the above options.
#   start $mode
#     - Start FPP in a new window.
#     - edit: FPP will launch an editor in that temporary window.
#     - paste: Pastes the selected file list back into the original pane.
#
# There are also internal entry points for handling the behaviour above:
#   internal_run
#     - Invoked in then new window; launches FPP itself and performs cleanup.
#   internal_finish_paste
#     - Invoked by FPP, if using paste mode, after selecting files.
#     - Handles pasting the file list into the original buffer.

# Bind the key to run the "start" command.
# Defaults to 'f' using mode 'edit'.
tmux_fpp_init() {
  local should_bind key mode

  # @fpp-bind can be set to 'off' to prevent binding keys,
  # in case the user wants to do all the binding on their own.
  # By default, we will bind keys.
  should_bind="$(tmux show-option -gqv @fpp-bind)" || true
  : "${should_bind:=on}"

  # If @fpp-bind was set to anything except 'on', do not bind.
  [ "${should_bind}" = on ] || return 0

  # @fpp-key determines which key to bind.
  # Defaults to 'f'.
  key="$(tmux show-option -gqv @fpp-key)" || true
  : "${key:=f}"

  # @fpp-mode can be 'edit' or 'paste'.
  # Defaults to 'edit'.
  mode="$(tmux show-option -gqv @fpp-mode)" || true
  : "${mode:=edit}"

  tmux bind-key -N "Facebook Path Picker" "${key}" run-shell "$(printf '%q start %q' "${BASH_SOURCE[0]}" "${mode}")"
}

# Save the buffer contents and create a new window for running FPP.
tmux_fpp_start() {
  local fpp_path mode target_pane_id mode tmpfile

  # @fpp-path determines path to FPP.
  # Defaults to 'fpp'.
  fpp_path="$(tmux show-option -gqv @fpp-path)" || true
  : "${fpp_path:=fpp}"

  # Display error if fpp is not found.
  if ! command -v "${fpp_path}" &> /dev/null; then
      tmux display-message "tmux-fpp: fpp is not found"
      # Intentionally not returning non zero here to exit gracefully.
      return
  fi

  # Remember the invocation mode
  mode="${1}"

  # Remember the current pane ID
  target_pane_id="$(tmux display -p '#{pane_id}')" || return $?

  # Create a temporary file to hold the pane contents
  tmpfile="$(mktemp -t tmux-fpp-buffer.XXXXXX)" || return $?

  # If we exit prematurely, clean up the temp file.
  # Otherwise, it's cleaned up in the "run" invocation after piping to fpp.
  trap 'rm -f "${tmpfile}"' ERR RETURN

  # Save the pane contents to the temporary file.
  tmux capture-pane -Jp > "${tmpfile}"

  # Create a new window, running the "tmux_fpp_internal_run" function.
  # It will run fpp and clean up the temp file.
  tmux \
    new-window \
      -n fpp \
      -c '#{pane_current_path}' \
      "${BASH_SOURCE[0]}" internal_run \
      "${mode}" "${target_pane_id}" "${tmpfile}" "${fpp_path}" \
      ;

  # If we made it here, the new window (tmux_fpp_internal_run) will handle cleanup.
  trap - ERR RETURN
}

# Execute FPP and clean up the temporary buffer contents file.
tmux_fpp_internal_run() {
  local mode target_pane_id tmpfile
  mode="${1}"
  target_pane_id="${2}"
  tmpfile="${3}"
  fpp_path="${4}"

  # Clean up the temp file at the end, no matter what.
  trap 'rm -f "${tmpfile}"' ERR RETURN

  # Construct the command arguments for running fpp.
  local fpp_cmd
  fpp_cmd=($fpp_path)
  case "${mode}" in
    paste)
      # In 'paste' mode, we execute tmux_fpp_finish_paste with the file list.
      # This pastes the selected file list into the original pane.
      fpp_cmd+=(-c "${BASH_SOURCE[0]}" internal_finish_paste "${target_pane_id}")
      ;;
    edit|*)
      # In 'edit' mode, just let fpp do what it would normally do
      # (i.e. launch EDITOR or FPP_EDITOR in the fpp window).
      ;;
  esac

  # Run fpp with the buffer contents.
  "${fpp_cmd[@]}" < "${tmpfile}"

  # (The trap will remove tmpfile at the end).
}

# Executed after FPP completes if we ran in 'paste' mode.
# Paste the quoted list of file names back into the original buffer.
tmux_fpp_internal_finish_paste() {
  local target_pane_id
  target_pane_id="${1}"
  shift

  # Quote each of the file arguments
  local output f
  output=()
  for f in "$@"; do
    output+=("$(printf %q "$f")")
  done

  # Paste the list of files back to our original pane.
  tmux \
    set-buffer "${output[*]}" ';' \
    paste-buffer -t "${target_pane_id}" ';' \
    ;
}

# Choose the function to run based on the arguments.
run_func() {
  local func
  func="tmux_fpp_${1:-init}"

  if [ "$(type -t "${func}" || true)" = function ]; then
    "${func}" "${@+${@:2}}"
  else
    echo 'Bad arguments: $*' >&2
    return 1
  fi
}

run_func "$@"
