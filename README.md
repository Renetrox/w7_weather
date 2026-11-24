# W7 Weather — Aero experimental
Conky + Lua/Cairo para X11. Conserva el único PNG original. Tonalidades dinámicas, iconos vectoriales, transparencia, escala y animaciones opcionales. Configuración mediante Dialog.

Instalar dependencias (Debian/MX): sudo apt install conky-all curl dialog

Clonar en ~/.conky/w7_weather o definir W7_WEATHER_DIR con la ruta absoluta. Ejecutar:
```sh
cd ~/.conky/w7_weather
bash settings.sh
bash weather.sh
conky -c "$PWD/conky.conf"
```
Cerrar únicamente la instancia del gadget antes de relanzarlo; no usar killall conky si hay otros widgets. El menú guarda settings.conf localmente. La noche sigue usando el reloj local (19–06); la fuente es wttr.in. El asterisco indica datos en caché. Animaciones desactivadas por defecto. Rama experimental: requiere prueba visual en X11.
