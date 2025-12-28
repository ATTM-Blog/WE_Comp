#!/usr/bin/env bash
SESSION=wecomp

tmux has-session -t $SESSION 2>/dev/null && exec tmux attach -t $SESSION

tmux new-session -d -s $SESSION -n Workspace
tmux split-window -v -p 35
tmux send-keys "NNN_OPENER=~/nnn-opener-tmux nnn" C-m
tmux send-keys -t 1 "echo 'Tool pane ready'" C-m
exec tmux attach -t $SESSION
