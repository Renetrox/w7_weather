#!/usr/bin/env bash

OUT="$HOME/.conky/w7_weather/weather.txt"
CITY="Asuncion"

DATA=$(curl -fsSL "https://wttr.in/${CITY}?format=%t|%C" 2>/dev/null)

if [ -z "$DATA" ]; then
  echo "--°C" > "$OUT"
  echo "$CITY" >> "$OUT"
  echo "offline" >> "$OUT"
  exit 0
fi

TEMP=$(echo "$DATA" | cut -d'|' -f1 | sed 's/^+//')
COND=$(echo "$DATA" | cut -d'|' -f2 | tr '[:upper:]' '[:lower:]')

STATE="cloudy"
[[ "$COND" == *sun* || "$COND" == *clear* ]] && STATE="sunny"
[[ "$COND" == *rain* || "$COND" == *shower* ]] && STATE="rain"

HOUR=$(date +%H)
[ "$HOUR" -ge 19 ] || [ "$HOUR" -le 6 ] && STATE="night"

echo "$TEMP" > "$OUT"
echo "$CITY" >> "$OUT"
echo "$STATE" >> "$OUT"
