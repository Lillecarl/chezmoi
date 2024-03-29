#! /usr/bin/env xonsh

# XONSH WEBCONFIG START
# XONSH WEBCONFIG END

# Standard imports
import time
import json
import platform
import os
from prompt_toolkit.keys import Keys
from shutil import which

# Set shell to xonsh (We're going to spawn a new shell)
$SHELL = "xonsh"

# Ask if we wanna launch Zellij if we're not inside of it
# If ZELLIJ env var exists we don't wanna spawn it again
if "ZELLIJ" in ${...}:
  pass
# If zellij exists, ask if we wanna launch it
elif which("zellij") is not None:
  if input("Wanna launch Zellij? Y/n: ") != "n":
    # Attach to default session if it exists
    if $(zellij list-sessions 2> /dev/null | grep default):
      exec zellij attach default
    else:
      # Spawn new default session
      exec zellij -s default

# xontribs

# Execute direnv in Xonsh
xontrib load direnv
# Allow banging shell scripts from xonsh
xontrib load sh
# Search previous commands output with Alt+f
$XONSH_CAPTURE_ALWAYS=True # Required for output_search
xontrib load output_search
# Replaces McFly, loads history into a fuzzy searcher TUI
$fzf_history_binding = Keys.ControlR
xontrib load fzf-widgets

# Because modal text editing makes sense
$VI_MODE = True
# Makes "cd" bareable with beautiful paths
$CASE_SENSITIVE_COMPLETIONS = False

# Add bash completions to xonsh, not sure how this works but it's heaps cool.
$BASH_COMPLETIONS= ["/run/current-system/sw/share/bash-completion/bash_completion"]
# Helm completion
source-bash $(helm completion bash) --suppress-skip-message


# Use SQLite history backend
$XONSH_HISTORY_BACKEND = 'sqlite'

# Starship prompt
execx($(starship init xonsh))

$EDITOR = "nvim"
$VISUAL = "nvim"

# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#variables
if "XDG_CACHE_HOME" not in ${...}:
  $XDG_CACHE_HOME = $HOME/.cache
if "XDG_CONFIG_HOME" not in ${...}:
  $XDG_CONFIG_HOME = $HOME/.config
if "XDG_BIN_HOME" not in ${...}:
  $XDG_BIN_HOME = $HOME/.local/bin
if "XDG_DATA_HOME" not in ${...}:
  $XDG_DATA_HOME = $HOME/.local/share
if "XDG_STATE_HOME" not in ${...}:
  $XDG_STATE_HOME = $HOME/.local/state
if "NODE_HOME" not in ${...}:
  $XDG_STATE_HOME = $HOME/.local/node

# Add XDG_BIN_HOME to $PATH
$PATH.add($XDG_BIN_HOME)

# Add note stuff to $PATH
$PATH.add($NODE_HOME)
$NODE_PATH=$NODE_HOME+"/lib/node_modules"


# Load keychain bash environment stuff
source-bash $(keychain --eval -q) --suppress-skip-message
# If keychain binary exists, load ed25519 key
if which("keychain"):
  keychain -q id_ed25519
  # Add work keys to work machine
  if os.uname()[1] == "nub":
    keychain -q ed_viaplay
    keychain -q rsa_viaplay

