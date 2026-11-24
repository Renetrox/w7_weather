require 'cairo'
local root=os.getenv("W7_WEATHER_DIR") or (os.getenv("HOME").."/.conky/w7_weather")
local p=dofile(root.."/prefs.lua").load()
local bg=cairo_image_surface_create_from_png(root.."/assets/weather_bg.png")
local themes={sunny={0.12,0.48,0.9},partly={0.27,0.48,0.72},cloudy={0.38,0.43,0.51},rain={0.16,0.28,0.41},storm={0.23,0.19,0.37},night={0.04,0.09,0.23},snow={0.53,0.64,0.76},fog={0.48,0.49,0.53},offline={0.35,0.35,0.35},dark={0.12,0.14,0.19}}
local glyph={sunny="☀",partly="☁",cloudy="☁",rain="☂",storm="ϟ",night="☾",snow="❄",fog="≋",offline="?"}
local labels={sunny="Soleado",partly="Parcialmente nublado",cloudy="Nublado",rain="Lluvia",storm="Tormenta",night="Noche despejada",snow="Nieve",fog="Niebla",offline="Sin conexión"}
local function read()
 local f=io.open(root.."/weather.txt","r")
 if not f then return "--","Ciudad","offline","","stale" end
 local t,c,s,d,a=f:read("*l","*l","*l","*l","*l");f:close()
 return t or "--",c or "Ciudad",s or "offline",d or "",a or "fresh"
end
local function rgba(cr,r,g,b,a) cairo_set_source_rgba(cr,r,g,b,a or 1) end
local function text(cr,t,x,y,size,maxw,bold)
 cairo_select_font_face(cr,p.font,CAIRO_FONT_SLANT_NORMAL,bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)
 cairo_set_font_size(cr,size)
 local e=cairo_text_extents_t:create()
 cairo_text_extents(cr,t,e)
 if e.x_advance>maxw then cairo_set_font_size(cr,size*maxw/e.x_advance) end
 rgba(cr,0,0,0,.45);cairo_move_to(cr,x+1,y+1);cairo_show_text(cr,t)
 rgba(cr,1,1,1,.98);cairo_move_to(cr,x,y);cairo_show_text(cr,t)
end
local function circle(cr,x,y,r) cairo_new_path(cr);cairo_arc(cr,x,y,r,0,2*math.pi) end
local function gradient(cr,x,y,r,a,b)
 local g=cairo_pattern_create_radial(x-r*.25,y-r*.35,1,x,y,r)
 cairo_pattern_add_color_stop_rgb(g,0,a[1],a[2],a[3]);cairo_pattern_add_color_stop_rgb(g,1,b[1],b[2],b[3])
 cairo_set_source(cr,g);cairo_fill(cr);cairo_pattern_destroy(g)
end
local function sun(cr,x,y,r,phase)
 rgba(cr,1,.76,.13);cairo_set_line_width(cr,2.5);cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)
 for i=0,11 do local a=i*math.pi/6+phase; cairo_move_to(cr,x+math.cos(a)*(r+3),y+math.sin(a)*(r+3));cairo_line_to(cr,x+math.cos(a)*(r+8),y+math.sin(a)*(r+8)) end
 cairo_stroke(cr);circle(cr,x,y,r);gradient(cr,x,y,r,{1,.98,.68},{.98,.55,.06})
end
local function cloud(cr,x,y)
 cairo_new_path(cr);cairo_move_to(cr,x-21,y+10)
 cairo_curve_to(cr,x-35,y+10,x-34,y-10,x-18,y-11)
 cairo_curve_to(cr,x-16,y-30,x+12,y-29,x+16,y-10)
 cairo_curve_to(cr,x+35,y-15,x+37,y+10,x+22,y+10);cairo_close_path(cr)
 local g=cairo_pattern_create_linear(0,y-24,0,y+12);cairo_pattern_add_color_stop_rgb(g,0,1,1,1);cairo_pattern_add_color_stop_rgb(g,1,.54,.66,.79)
 cairo_set_source(cr,g);cairo_fill(cr);cairo_pattern_destroy(g)
end
local function moon(cr,x,y)
 cairo_new_path(cr);cairo_arc(cr,x,y,21,.55,4.85);cairo_curve_to(cr,x-5,y-2,x+4,y+16,x+18,y+11);cairo_close_path(cr)
 gradient(cr,x,y,22,{1,.99,.86},{.78,.69,.38})
end
local function icon(cr,s,night,phase)
 if p.icons=="classic" then text(cr,glyph[s] or "?",33,65,49,60,true);return end
 if s=="sunny" then sun(cr,53,44,18,phase)
 elseif s=="night" then moon(cr,53,44)
 elseif s=="offline" then text(cr,"?",42,61,45,50,true)
 else
  if night then moon(cr,65,32) elseif s=="partly" then sun(cr,66,30,13,phase) end
  cloud(cr,51,44)
  if s=="rain" or s=="storm" or s=="snow" then
   rgba(cr,.72,.9,1);cairo_set_line_width(cr,2)
   for i=0,3 do local x=35+i*11;local y=59+(phase*12+i*3)%6
    if s=="snow" then circle(cr,x,y+3,2);cairo_fill(cr) else cairo_move_to(cr,x,y);cairo_line_to(cr,x-3,y+7);cairo_stroke(cr) end
   end
   if s=="storm" then rgba(cr,1,.86,.25);cairo_move_to(cr,56,53);cairo_line_to(cr,47,64);cairo_line_to(cr,55,64);cairo_line_to(cr,48,76);cairo_line_to(cr,65,60);cairo_line_to(cr,57,60);cairo_close_path(cr);cairo_fill(cr) end
  elseif s=="fog" then rgba(cr,.9,.94,.98);for i=0,2 do cairo_move_to(cr,28,58+i*4);cairo_line_to(cr,76,58+i*4) end;cairo_stroke(cr) end
 end
end
local function background(cr,s,night)
 if cairo_surface_status(bg)~=0 then return end
 local iw,ih=cairo_image_surface_get_width(bg),cairo_image_surface_get_height(bg)
 cairo_save(cr)
 -- Crop transparent outer padding, retain the original artwork.
 cairo_scale(cr,220/(iw*.76),100/(ih*.78));cairo_translate(cr,-iw*.127,-ih*.115)
 cairo_push_group(cr)
 cairo_set_source_surface(cr,bg,0,0);cairo_paint(cr)
 local tint=p.theme=="auto" and themes[night and "night" or s] or themes[p.theme]
 if tint then
  cairo_set_operator(cr,CAIRO_OPERATOR_ATOP);rgba(cr,tint[1],tint[2],tint[3],night and .62 or .40);cairo_paint(cr)
 end
 cairo_pop_group_to_source(cr);cairo_set_operator(cr,CAIRO_OPERATOR_OVER)
 cairo_paint_with_alpha(cr,math.max(0,math.min(100,tonumber(p.opacity) or 90))/100)
 cairo_restore(cr)
end
local tick=0
function conky_draw_w7_weather()
 if not conky_window then return end
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs)
 cairo_scale(cr,conky_window.width/220,conky_window.height/100)
 local t,c,s,d,a=read()
 local night=s=="night" or s:sub(1,6)=="night_"
 if s:sub(1,6)=="night_" then s=s:sub(7) end
 tick=tick+1;local phase=p.animation=="on" and tick*.045 or 0
 background(cr,s,night);icon(cr,s,night,phase)
 text(cr,t,103,44,29,105,true);text(cr,c,104,64,13,104,false)
 if p.footer=="on" then
  local label=(labels[s] or d);if night and s~="night" then label=label.." · Noche" end
  if a=="stale" then label=label.." *" end
  text(cr,label,13,92,10,194,false)
 end
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
