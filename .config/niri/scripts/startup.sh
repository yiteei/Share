#!/bin/bash
set +e

dms run -d
lianwall start
fcitx5 -d
wl-paste --watch cliphist store &
aria2c &
chameleos &
