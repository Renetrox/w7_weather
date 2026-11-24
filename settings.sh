#!/usr/bin/env bash
set -u
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FILE="$ROOT/settings.conf"
command -v dialog >/dev/null || { echo 'Instale dialog: sudo apt install dialog'; exit 1; }
get(){ local v; v=$(sed -n "s/^$1=//p" "$FILE" 2>/dev/null | tail -1); printf '%s' "${v:-$2}"; }
save(){ local tmp; tmp=$(mktemp "$ROOT/.settings.XXXXXX") || return; if [[ -f "$FILE" ]]; then grep -v "^$1=" "$FILE" > "$tmp" || true; fi; printf '%s=%s\n' "$1" "$2" >> "$tmp"; mv -f "$tmp" "$FILE"; }
choose(){ local key=$1 title=$2; shift 2; local v; v=$(dialog --stdout --menu "$title" 18 58 10 "$@") && save "$key" "$v"; }
while true; do
 item=$(dialog --stdout --title 'W7 Weather · Aero' --menu 'Cambios al reiniciar el gadget' 22 65 14 city 'Ciudad' unit 'Unidades' theme 'Tonalidad' opacity 'Transparencia del fondo' icons 'Iconos' scale 'Tamaño' position 'Posición' animation 'Animaciones' font 'Fuente' footer 'Franja inferior' interval 'Actualización' reset 'Restaurar valores' exit 'Salir') || break
 case "$item" in
 city|font) default=Asuncion; [[ "$item" == font ]] && default='DejaVu Sans'; v=$(dialog --stdout --inputbox "$item" 9 55 "$(get "$item" "$default")") && [[ -n "$v" && "$v" != *$'\n'* ]] && save "$item" "$v";;
 unit) choose unit Unidades C Celsius F Fahrenheit;;
 theme) choose theme Tonalidad auto Dinámica original Original dark Oscura sunny Azul cloudy Gris night Nocturna;;
 opacity) choose opacity Opacidad 100 '100%' 90 '90%' 75 '75%' 50 '50%' 25 '25%' 0 'Solo texto e iconos';;
 icons) choose icons Iconos aero Aero classic Clásicos;;
 scale) choose scale Tamaño 75 Pequeño 100 Normal 125 Grande 150 'Muy grande' 200 Doble;;
 position) choose position Posición top_right 'Arriba derecha' middle_right 'Centro derecha' bottom_right 'Abajo derecha' top_left 'Arriba izquierda' middle_left 'Centro izquierda' bottom_left 'Abajo izquierda';;
 animation|footer) choose "$item" "$item" on Activado off Desactivado;;
 interval) choose interval 'Intervalo' 300 '5 min' 900 '15 min' 1800 '30 min' 3600 '60 min';;
 reset) dialog --yesno '¿Restaurar valores?' 7 45 && rm -f "$FILE";;
 exit) break;;
 esac
done
clear
echo "Preferencias guardadas. Reinicie únicamente W7 Weather para aplicarlas."
