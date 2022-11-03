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

# Fixes xonsh showing it's executing cat when doing nothing, some kind of bug that i just worked around.
source ~/.config/xonsh/job.py
$PROMPT_FIELDS["current_job"] = CurrentJobField()

# xontribs
#
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

# Use SQLite history backend
$XONSH_HISTORY_BACKEND = 'sqlite'

# Starship prompt
execx($(starship init xonsh))

$EDITOR = "vim"
$VISUAL = "vim"

# Better ls
aliases["ls"] = "exa -lah"
# Go to git root folder
aliases['grt'] = lambda: os.chdir($(git rev-parse --show-toplevel).strip())

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

aliases["vim"] = "nvim"

def _tfswitch(args, stdin=None):
  /usr/bin/env tfswitch -b $XDG_BIN_HOME/terraform @(args)

aliases["tfswitch"] = _tfswitch

def _blueprofile(args, stdin=None):
  profile = None

  card: str = $(pactl list cards short | grep bluez | awk '{print $1 }')

  if args[0] == "mic":
    profile = "headset-head-unit"
  elif args[0] == "music":
    profile = "a2dp-sink"

  if len(card) <= 0:
    print("Found no suitable bluetooth \"card\"")
    profile = None

  if profile:
    print("Switching profile")
    pactl set-card-profile @(card) @(profile)
    if profile == "headset-head-unit":
      pactl set-default-source $(pactl list sources short | rg bluez_input | awk '{ print $1 }') # Switch this when switching from bluetooth too

aliases["blueprofile"] = _blueprofile

aliases["bluemic"] = lambda x: _blueprofile(args=["mic"])
aliases["bluesound"] = lambda x: _blueprofile(args=["music"])
