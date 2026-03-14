#!/bin/bash

# Pywal renklerini yükle
source "$HOME/.cache/wal/colors.sh"

# Renklerden # işaretini kaldır (RRGGBB formatı için)
BG="${background:1}"
FG="${foreground:1}"
C1="${color1:1}"
C2="${color2:1}"

swaylock \
    --screenshots \
    --clock \
    --indicator \
    --indicator-radius 100 \
    --indicator-thickness 7 \
    --effect-blur 7x5 \
    --effect-vignette 0.5:0.5 \
    --ring-color "$C1" \
    --key-hl-color "$C2" \
    --text-color "$FG" \
    --line-color 00000000 \
    --inside-color "${BG}88" \
    --separator-color 00000000 \
    --inside-ver-color "${C1}88" \
    --ring-ver-color "$C1" \
    --inside-wrong-color "ff555588" \
    --ring-wrong-color "ff5555"
