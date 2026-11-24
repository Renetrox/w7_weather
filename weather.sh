#!/usr/bin/env bash
set -u
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CITY=Asuncion
UNIT=C
while IFS='=' read -r key value; do
 case "$key" in city) CITY="$value";; unit) UNIT="$value";; esac
done < <(cat "$ROOT/settings.conf" 2>/dev/null || true)
[[ "$UNIT" == F ]] && units=u || units=m
OUT="$ROOT/weather.txt"
tmp=$(mktemp "$ROOT/.weather.XXXXXX") || exit 1
trap 'rm -f "$tmp"' EXIT
DATA=$(curl -fsSL --connect-timeout 8 --max-time 20 --get --data-urlencode 'format=%t|%C' --data-urlencode "$units=" "https://wttr.in/$(printf '%s' "$CITY" | od -An -v -tx1 | tr -d ' \n' | sed 's/../%&/g')" 2>/dev/null) || DATA=
if [[ "$DATA" != *'|'* ]]; then
 if [[ -s "$OUT" ]]; then
  mapfile -t old < "$OUT"
  printf '%s\n' "${old[0]:---}" "${old[1]:-$CITY}" "${old[2]:-offline}" "${old[3]:-}" stale > "$tmp"
 else printf '%s\n' '--' "$CITY" offline 'Sin conexión' stale > "$tmp"; fi
else
 TEMP=${DATA%%|*}; TEMP=${TEMP#+}; COND=${DATA#*|}; low=${COND,,}
 STATE=cloudy
 case "$low" in *thunder*) STATE=storm;; *snow*|*sleet*) STATE=snow;; *fog*|*mist*) STATE=fog;; *rain*|*shower*|*drizzle*) STATE=rain;; *partly*) STATE=partly;; *sun*|*clear*) STATE=sunny;; esac
 HOUR=$(date +%H)
 if ((10#$HOUR >= 19 || 10#$HOUR <= 6)); then
  case "$STATE" in sunny) STATE=night;; *) STATE="night_$STATE";; esac
 fi
 printf '%s\n' "$TEMP" "$CITY" "$STATE" "$COND" fresh > "$tmp"
fi
mv -f "$tmp" "$OUT"
