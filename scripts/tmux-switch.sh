#!/usr/bin/env bash
pane=$(tmux list-panes -F '#{pane_id} #{pane_top}' | sort -k2n | head -1 | cut -d' ' -f1)

case "$1" in
  git) cmd=gitui ;;
  monitor) cmd="btop || htop" ;;
  term) cmd=bash ;;
  edit) cmd=vim ;;
  view) cmd="less -S" ;;
esac

tmux send-keys -t "$pane" C-c "clear; $cmd" C-m
