#!/usr/bin/env bash

xmodmap -e "pointer = 3 2 1"
run picom -b
