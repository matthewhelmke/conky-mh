#!/bin/bash

###############################################################################
# get_ups_info.sh
#
# Makes a single "sudo pwrstat -status" call and writes each value to its own
# line in a cache file for Conky to read individually. Mirrors get_gpu_info.sh.
#
# Cache file line order:
#   Line 1: State (e.g. Normal)
#   Line 2: Battery capacity (%)   -- number only
#   Line 3: Remaining runtime      -- number only, minutes
#
# Values are parsed by stripping the label and its dot leader, not by column
# position, so a change in CyberPower's field widths will not break it.
###############################################################################

CACHE_FILE=~/conky/data_files/ups_info.txt

status=$(sudo pwrstat -status)

{
  grep 'State'             <<<"$status" | sed -E 's/^.*\.\.+ *//; s/ *$//'
  grep 'Battery Capacity'  <<<"$status" | grep -oE '[0-9]+'
  grep 'Remaining Runtime' <<<"$status" | grep -oE '[0-9]+'
} > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"
