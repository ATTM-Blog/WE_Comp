#!/usr/bin/env bash
case "$1" in
  py)
    tmux new-window -n PyCode "vim main.py"
    tmux split-window -h "python3 main.py"
    ;;
  c)
    tmux new-window -n CCode "vim main.c"
    tmux split-window -h "gcc main.c -o main && ./main"
    ;;
esac
