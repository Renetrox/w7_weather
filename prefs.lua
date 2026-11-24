local M={}
M.root=os.getenv("W7_WEATHER_DIR") or (os.getenv("HOME").."/.conky/w7_weather")
M.defaults={city="Asuncion",unit="C",theme="auto",opacity="90",icons="aero",scale="100",position="middle_right",animation="off",font="DejaVu Sans",footer="on",interval="900"}
function M.load()
 local p={}
 for k,v in pairs(M.defaults) do p[k]=v end
 local f=io.open(M.root.."/settings.conf","r")
 if f then for line in f:lines() do local k,v=line:match("^([%w_]+)=(.*)$"); if k and p[k] then p[k]=v end end; f:close() end
 return p
end
return M
