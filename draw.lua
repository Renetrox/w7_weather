require 'cairo'

-- =========================
-- CONFIG
-- =========================
local BG_PNG = "/home/Reneto/.conky/w7_weather/assets/weather_bg.png"

-- =========================
-- UTILS
-- =========================
local function read_state()
  local f = io.open(os.getenv("HOME") .. "/.conky/w7_weather/weather.txt","r")
  if not f then return "--°C","Ciudad","offline" end
  local t = f:read("*l") or "--°C"
  local c = f:read("*l") or "Ciudad"
  local s = f:read("*l") or "offline"
  f:close()
  return t,c,s
end

local function draw_png(cr, path, x, y, w, h)
  local img = cairo_image_surface_create_from_png(path)
  local iw = cairo_image_surface_get_width(img)
  local ih = cairo_image_surface_get_height(img)

  cairo_save(cr)
  cairo_translate(cr, x, y)
  cairo_scale(cr, w / iw, h / ih)
  cairo_set_source_surface(cr, img, 0, 0)
  cairo_paint(cr)
  cairo_restore(cr)

  cairo_surface_destroy(img)
end

local function draw_text(cr, txt, x, y, size, r,g,b,a, bold)
  cairo_save(cr)
  cairo_select_font_face(
    cr,
    "DejaVu Sans",
    CAIRO_FONT_SLANT_NORMAL,
    bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL
  )
  cairo_set_font_size(cr, size)
  cairo_set_source_rgba(cr, r,g,b,a)
  cairo_move_to(cr, x, y)
  cairo_show_text(cr, txt)
  cairo_restore(cr)
end

-- Devuelve el icono clásico junto con sus valores de color R, G, B
local function pick_icon(state)
  if state == "sunny" then 
    return "☀", 1.0, 0.85, 0.0      -- Amarillo brillante
  elseif state == "cloudy" then 
    return "☁", 0.75, 0.82, 0.88    -- Gris azulado suave
  elseif state == "rain" then 
    return "☂", 0.22, 0.65, 1.0     -- Azul lluvia
  elseif state == "night" then 
    return "☾", 0.92, 0.92, 0.65    -- Amarillo Luna tenue
  elseif state == "offline" then 
    return "☹", 1.0, 0.35, 0.35     -- Rojo alerta
  end
  return "?", 1.0, 1.0, 1.0         -- Blanco por defecto
end

-- =========================
-- MAIN DRAW
-- =========================
function conky_draw_w7_weather()
  if conky_window == nil then return end

  local cs = cairo_xlib_surface_create(
    conky_window.display,
    conky_window.drawable,
    conky_window.visual,
    conky_window.width,
    conky_window.height
  )
  local cr = cairo_create(cs)

  local temp, city, state = read_state()

  -- Fondo PNG Win7
  draw_png(cr, BG_PNG, 0, 0, conky_window.width, conky_window.height)

  -- Icono Dinámico con Color e Iconos Clásicos
  local icon, icon_r, icon_g, icon_b = pick_icon(state)
  -- Sombra proyectada del icono (fija en negro transparente)
  draw_text(cr, icon, 37, 66, 74, 0, 0, 0, 0.40, true)
  -- Icono frontal con color personalizado segun el clima
  draw_text(cr, icon, 36, 65, 74, icon_r, icon_g, icon_b, 0.92, true)

  -- Temperatura
  draw_text(cr, temp, 128, 42, 26, 0,0,0,0.45, true)
  draw_text(cr, temp, 127, 41, 26, 1,1,1,0.95, true)

  -- Ciudad
  draw_text(cr, city, 131, 62, 11, 0,0,0,0.40, false)
  draw_text(cr, city, 132, 61, 11, 1,1,1,0.85, false)

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
end
