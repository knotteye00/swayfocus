# This repository is a mirror
Head to https://pond.waldn.net/git/knotteye/swayfocus to contribute

# SWAYFOCUS - Window Switching Tool For Sway

A tool to focus a specific window in sway, useful for run or raise scripts that would have used xdotool or wmctrl under Xorg.
Uses swaymsg to communicate. Windows hidden to the system tray don't show up in the get_tree command, so they can't be raised with this.

## Usage
```
Usage: swayfocus [OPTIONS]
    -v, --version                    Show Version
    -h, --help                       Show Help
    -p, --print                      Print window names and exit
    -c, --cycle                      Cycle through all matching windows in order, instead of selecting the first in the list    
	-n WNAME, --name=WNAME           Match against window name
    -m WMARK, --mark=WMARK           Match against window mark
    -t WTYPE, --type=WTYPE           Match against window type (app_id for wayland, class for xwayland)
```
Select at least one matching option.

## Examples
```
swayfocus -p | sort -u | bemenu | xargs swayfocus -c --name=
# simple window switcher
```

## Installation
```
make && sudo make install
```
