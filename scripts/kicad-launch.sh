#!/usr/bin/env bash
[ -n "$DISPLAY" ] && exec kicad
exec startx /usr/bin/kicad -- :0
