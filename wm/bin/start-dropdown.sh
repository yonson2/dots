#!/usr/bin/env bash

tabbed -r 2 -n "drop-down-st" st -w '' &!

xdotool search --classname "drop-down-st" > ~/.cache/dropdown-id
