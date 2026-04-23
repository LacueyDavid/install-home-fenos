#!/usr/bin/env bash
pkill -9 -f "quickshell -c"
sleep 0.5
hyprctl reload
quickshell -c ii &
