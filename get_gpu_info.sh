#!/bin/bash

###############################################################################
# get_gpu_info.sh
#
# Copyright (c) 2026 Matthew Helmke
#
# Uses nvidia-smi to fetch NVIDIA GPU information.
#
# Makes a single nvidia-smi call and writes each value to its own line
# in a cache file for Conky to read individually.
#
# Cache file line order:
#   Line 1: GPU model name
#   Line 2: Driver version
#   Line 3: GPU utilization (%)
#   Line 4: Performance state
#   Line 5: Temperature (°C)
#   Line 6: Memory used (MiB)
#   Line 7: Memory total (MiB)
###############################################################################

CACHE_FILE=~/conky/data_files/gpu_info.txt

nvidia-smi \
  --query-gpu=name,driver_version,utilization.gpu,pstate,temperature.gpu,memory.used,memory.total \
  --format=csv,noheader,nounits \
| tr ',' '\n' \
| sed 's/^ *//' \
> "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"