#!/bin/bash
sleep 5 &&
nice -n 12 conky -d -c ~/conky/conkyrc_main &
sleep 5 &&
nice -n 12 conky -d -c ~/conky/conkyrc_weather &
