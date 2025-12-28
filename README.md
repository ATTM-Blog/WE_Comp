# WE·COMP — Engineering Workstation (Pi-top v2 / Raspberry Pi OS Lite)

WE-Comp is a terminal-first workstation environment built on **tmux**:

- Greyscale “workstation chrome” (VAX/Sun/SGI feel)
- Amber accent for focus/identity
- Top pane: **nnn** file manager
- Bottom pane: switchable tools (vim/less/gitui/btop/bash)
- Status bar: battery, CPU, RAM, disk, Wi-Fi, IP, time (burn-in drift/rotation)
- Python + C “IDE windows” (vim + run pane)
- Installs Python **control** toolbox (`control>=0.10.2`)
- Includes **KiCad** support (adds minimal X11 so KiCad can launch on Lite)
- Includes **NetSurf** lightweight browser (launches via startx)

## Install

```bash
cd ~
git clone <YOUR_REPO_URL> WE-Comp
cd WE-Comp
chmod +x install.sh
./install.sh
