#! /bin/bash

###############################################################################
# get_weather_report.sh
#
# Copyright (c) 2026 Matthew Helmke
#
# Uses the OpenWeather One Call API 3.0 to fetch and display weather data.
# See https://openweathermap.org/api/one-call-3
#
# A single API call returns current, hourly, and daily data.
# Units: imperial (°F, MPH)
#
###############################################################################


##################################
#### Configuration            ####
##################################

API_KEY="YOUR_API_KEY_HERE"
LAT="YOUR_LATITUDE_HERE"
LON="-YOUR_LONGITUDE_HERE"
WEATHER_DIR=~/conky/data_files
JSON="$WEATHER_DIR/openweathermap.json"


##################################
#### Pull JSON from API       ####
##################################

curl -sf "https://api.openweathermap.org/data/3.0/onecall?lat=${LAT}&lon=${LON}&units=imperial&appid=${API_KEY}" \
  > "$JSON"

# If the curl failed or returned an empty/invalid file, exit gracefully
if [ ! -s "$JSON" ]; then
  echo "Weather data unavailable."
  exit 1
fi


##################################
#### Helper functions         ####
##################################

# Convert a UNIX epoch to a readable date (e.g. "Fri Feb 21")
epoch_to_date() {
  date -d "@$1" "+%a %b %d"
}

# Convert a UNIX epoch to a readable time (e.g. " 3:00 PM")
epoch_to_time() {
  date -d "@$1" "+%l:%M %p"
}

# Convert wind degrees to a 16-point compass direction
degrees_to_compass() {
  local degree=$1
  local directions=("N" "NNE" "NE" "ENE" "E" "ESE" "SE" "SSE" "S" "SSW" "SW" "WSW" "W" "WNW" "NW" "NNW")
  local index=$(echo "scale=0; ($degree + 11.25) / 22.5" | bc)
  index=$((index % 16))
  echo "${directions[$index]}"
}

# Display a single hourly forecast block given an hourly array index
show_hourly_forecast() {
  local index=$1
  local dt
  dt=$(jq -r ".hourly[$index].dt" "$JSON")
  local time_label
  time_label=$(epoch_to_time "$dt")

  jq -r --arg label "$time_label" --argjson i "$index" '
    "Forecast for \($label)",
    " Condition:  \(.hourly[$i].weather[0].description)",
    " Temp:       \(.hourly[$i].temp | floor)°F",
    " Humidity:   \(.hourly[$i].humidity)%",
    " Precip:     \(.hourly[$i].pop * 100 | floor)%",
    " "
  ' "$JSON"
}

# Display a single daily forecast block given a daily array index
show_daily_forecast() {
  local index=$1
  local dt
  dt=$(jq -r ".daily[$index].dt" "$JSON")
  local date_label
  date_label=$(epoch_to_date "$dt")

  jq -r --arg label "$date_label" --argjson i "$index" '
    "Forecast for \($label)",
    " Summary:    \(.daily[$i].summary)",
    " High/Low:   \(.daily[$i].temp.max | floor)°F / \(.daily[$i].temp.min | floor)°F",
    " Humidity:   \(.daily[$i].humidity)%",
    " Precip:     \(.daily[$i].pop * 100 | floor)%",
    " "
  ' "$JSON"
}


##################################
#### Build display output     ####
##################################

# --- Alerts (shown only when present) ---
jq -r '.alerts[]? |
  "ALERT: \(.event) issued by \(.sender_name)",
  "\(.description)",
  " "
' "$JSON" 2>/dev/null


# --- Current conditions ---
WIND_DEG=$(jq -r '.current.wind_deg' "$JSON")
COMPASS=$(degrees_to_compass "$WIND_DEG")

TODAY_DT=$(jq -r '.daily[0].dt' "$JSON")
TODAY=$(epoch_to_date "$TODAY_DT")

jq -r --arg compass "$COMPASS" --arg date "$TODAY" '
  "WEATHER",
  "Current details for \($date)",
  " Condition:  \(.current.weather[0].main) - \(.current.weather[0].description)",
  " Temp:       \(.current.temp | floor)°F",
  " Feels like: \(.current.feels_like | floor)°F",
  " Humidity:   \(.current.humidity)%",
  " Wind speed: \(.current.wind_speed | floor) MPH",
  " Wind from:  \($compass)",
  " "
' "$JSON"


# --- Hourly forecasts ---
show_hourly_forecast 1
show_hourly_forecast 2
show_hourly_forecast 3
show_hourly_forecast 8


# --- Daily forecasts (tomorrow and day after) ---
show_daily_forecast 1
show_daily_forecast 2