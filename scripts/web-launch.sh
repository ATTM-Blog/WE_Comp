#!/usr/bin/env bash
[ -n "$DISPLAY" ] && exec netsurf
exec startx /usr/bin/netsurf -- :0
