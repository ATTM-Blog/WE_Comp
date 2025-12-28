#!/usr/bin/env bash
# WE-Comp installer (Pi-top v2 / Raspberry Pi OS Lite)
# - Amber-accent tmux workstation
# - python-control toolbox
# - MMBasic launcher binding
# - KiCad + minimal X11 (startx) so KiCad can open on Lite
# - NetSurf lightweight browser (startx)

set -euo pipefail

USER_HOME="$HOME"
USER_NAME="$(whoami)"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[WE-Comp] apt update..."
sudo apt update

echo "[WE-Comp] Installing base packages..."
sudo apt install -y \
  tmux nnn vim less git gitui btop htop \
  iw wireless-tools libraspberrypi-bin \
  unzip zip tree ripgrep \
  build-essential gdb \
  python3 python3-venv python3-pip \
  python3-numpy python3-scipy python3-matplotlib

echo "[WE-Comp] Installing minimal X11 + KiCad + NetSurf..."
sudo apt install -y \
  xserver-xorg xinit openbox xterm \
  kicad kicad-libraries \
  netsurf-gtk

# Optional extras (uncomment if you want)
# sudo apt install -y pandoc
# sudo apt install -y texlive-latex-base
# sudo apt install -y imagemagick

echo "[WE-Comp] Installing python-control toolbox (>=0.10.2) ..."
python3 -m pip install --user --upgrade pip setuptools wheel >/dev/null 2>&1 || true
python3 -m pip install --user "control>=0.10.2" || \
  echo "[WE-Comp] WARNING: python-control install failed (network/pip). Re-run later."

echo "[WE-Comp] Copying scripts to $USER_HOME ..."
cp -f "$REPO_DIR/scripts/sys-bar"           "$USER_HOME/sys-bar"
cp -f "$REPO_DIR/scripts/tmux-start.sh"     "$USER_HOME/tmux-start.sh"
cp -f "$REPO_DIR/scripts/tmux-switch.sh"    "$USER_HOME/tmux-switch.sh"
cp -f "$REPO_DIR/scripts/nnn-opener-tmux"   "$USER_HOME/nnn-opener-tmux"
cp -f "$REPO_DIR/scripts/code-ide.sh"       "$USER_HOME/code-ide.sh"
cp -f "$REPO_DIR/scripts/python-select.sh"  "$USER_HOME/python-select.sh"
cp -f "$REPO_DIR/scripts/wecomp-banner.sh"  "$USER_HOME/wecomp-banner.sh"
cp -f "$REPO_DIR/scripts/gen-icons.sh"      "$USER_HOME/gen-icons.sh"
cp -f "$REPO_DIR/scripts/kicad-launch.sh"   "$USER_HOME/kicad-launch.sh"
cp -f "$REPO_DIR/scripts/web-launch.sh"     "$USER_HOME/web-launch.sh"

chmod +x "$USER_HOME"/sys-bar \
         "$USER_HOME"/tmux-start.sh \
         "$USER_HOME"/tmux-switch.sh \
         "$USER_HOME"/nnn-opener-tmux \
         "$USER_HOME"/code-ide.sh \
         "$USER_HOME"/python-select.sh \
         "$USER_HOME"/wecomp-banner.sh \
         "$USER_HOME"/gen-icons.sh \
         "$USER_HOME"/kicad-launch.sh \
         "$USER_HOME"/web-launch.sh

echo "[WE-Comp] Copying assets to $USER_HOME/.wecomp-assets ..."
mkdir -p "$USER_HOME/.wecomp-assets"
cp -f "$REPO_DIR/assets/wecomp-dark.svg"   "$USER_HOME/.wecomp-assets/wecomp-dark.svg"
cp -f "$REPO_DIR/assets/wecomp-light.svg"  "$USER_HOME/.wecomp-assets/wecomp-light.svg"
cp -f "$REPO_DIR/assets/splash.txt"        "$USER_HOME/.wecomp-assets/splash.txt"

echo "[WE-Comp] Writing ~/.tmux.conf (greyscale + amber accent) ..."
cat > "$USER_HOME/.tmux.conf" <<EOF
set -g status on
set -g status-position bottom
set -g status-interval 60
set -g status-justify centre

# Left: WE-Comp glyph in amber; middle: window tabs; right: sys-bar
set -g status-left '#[fg=colour11]╱╲╱╲ #[fg=brightwhite]'
set -g status-right '#(/home/$USER_NAME/sys-bar)'

# Greyscale chrome + amber accent (apps keep their own colours)
set -g status-style "bg=black,fg=brightwhite"
set -g pane-border-style "fg=colour8"
set -g pane-active-border-style "fg=colour11"
set -g message-style "bg=black,fg=colour11"
set -g mode-style "bg=black,fg=colour11"
set -gu window-style
set -gu window-active-style

set -g window-status-current-format " #[fg=brightwhite]#I:#W "
set -g window-status-format " #[fg=colour8]#I:#W "

set -g default-terminal "screen-256color"
set -ga terminal-overrides ",*:Tc"

# Bottom pane switchers
bind g run-shell '~/tmux-switch.sh git'
bind l run-shell '~/tmux-switch.sh lazygit'
bind m run-shell '~/tmux-switch.sh monitor'
bind t run-shell '~/tmux-switch.sh term'
bind e run-shell '~/tmux-switch.sh edit'
bind v run-shell '~/tmux-switch.sh view'

# Coding IDE windows
bind-key P run-shell '~/code-ide.sh py'
bind-key C run-shell '~/code-ide.sh c'

# KiCad (GUI) on Lite
bind-key K new-window -n 'KiCad' '~/kicad-launch.sh'

# NetSurf lightweight browser
bind-key W new-window -n 'Web' '~/web-launch.sh'

# MMBasic window (expects 'mmbasic' on PATH)
bind-key B new-window -n 'MMBasic' 'mmbasic'
EOF

echo "[WE-Comp] Enabling auto-start in ~/.bashrc ..."
BASHRC="$USER_HOME/.bashrc"
if ! grep -q "WE-Comp Workbench auto-start" "$BASHRC" 2>/dev/null; then
  cat >> "$BASHRC" <<'SH'

# WE-Comp Workbench auto-start
if [ -t 1 ] && [ -z "$TMUX" ] && command -v tmux >/dev/null 2>&1; then
  ~/wecomp-banner.sh
  sleep 1
  ~/tmux-start.sh
fi
SH
fi

echo
echo "[WE-Comp] Install complete."
echo "  - Log out and back in, or run:  ~/tmux-start.sh"
echo "  - KiCad hotkey:                Ctrl-b K"
echo "  - Web hotkey (NetSurf):        Ctrl-b W"
echo "  - Python IDE hotkey:           Ctrl-b P"
echo "  - C IDE hotkey:                Ctrl-b C"
echo "  - MMBasic hotkey:              Ctrl-b B (once installed)"
