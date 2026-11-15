-- Representative terrain albedo, not the lit screen color. Sample the local
-- base texture and add averaged close-range macro/detail offsets. Nothing is
-- exported. Retained base bitmaps share an 8M-pixel (~32 MiB RGBA) budget.
local M = {}
local fallback = {mud={0.32,0.25,0.18}, dirt={0.48,0.39,0.27}, snow={0.88,0.92,0.96}}
local kinds = {MUD="mud",DIRT="dirt",DIRT_DUSTY="dirt",SAND="dirt",
  SANDY_ROAD="dirt",GRAVEL="dirt",SNOW="snow"}
local cache, cacheSize, retainedPixels = {}, 0, 0
local lastTerrain
local function finite(n) return type(n)=="number" and n==n and math.abs(n)<1e10 end
local function clamp(n) return math.max(0,math.min(1,n)) end

local function texture(path,retain)
  if type(path)~="string" or path=="" then return nil end
  if cache[path]~=nil then return cache[path] or nil end
  -- Do not evict and repeatedly decode textures in a contact callback.
  if cacheSize>=32 then return nil end
  cacheSize=cacheSize+1; cache[path]=false
  local ok, record=pcall(function()
    local bitmap=GBitmap()
    if not bitmap:loadFile(path) then return nil end
    local w,h=bitmap:getWidth(),bitmap:getHeight()
    if not finite(w) or not finite(h) or w<1 or h<1 then return nil end
    local result={0,0,0}
    local color=ColorI(0,0,0,255)
    for y=0,7 do for x=0,7 do
      if not bitmap:getColor(math.floor((x+0.5)*w/8),math.floor((y+0.5)*h/8),color) then return nil end
      local channels={color.r,color.g,color.b}
      for i=1,3 do
        if not finite(channels[i]) or channels[i]<0 or channels[i]>255 then return nil end
        result[i]=result[i]+channels[i]/(64*255)
      end
    end end
    local entry={rgb=result}
    if retain and retainedPixels+w*h<=8*1024*1024 then
      entry.bitmap=bitmap;entry.w=w;entry.h=h
      retainedPixels=retainedPixels+w*h
    end
    return entry
  end)
  if ok and record then cache[path]=record; return record end
end

local function terrainColor(kind,pos)
  if not core_terrain or not core_terrain.getTerrain or not GBitmap or not ColorI then return nil end
  local terrain=core_terrain.getTerrain()
  if not terrain then return nil end
  if terrain~=lastTerrain then
    cache={};cacheSize=0;retainedPixels=0;lastTerrain=terrain
  end
  -- Wheel positions can sit above the contact, but bridges/mesh surfaces must
  -- not borrow an unrelated terrain color far below them.
  local height=terrain:getHeight(pos)
  if not finite(height) or math.abs(pos.z-height)>1 then return nil end
  local idx=terrain:getMaterialIdxWs(pos)
  if not finite(idx) or idx<0 then return nil end
  local mat=terrain:getMaterial(idx)
  if not mat then return nil end
  local ground=mat:getField("groundmodelName",0)
  if type(ground)~="string" or kinds[string.upper(ground)]~=kind then return nil end
  local basePath=mat:getField("baseColorBaseTex",0)
  local modern=type(basePath)=="string" and basePath~=""
  if not modern then basePath=mat:getField("diffuseMap",0) end
  local base=texture(basePath,true)
  if not base then return nil end
  local rgb={base.rgb[1],base.rgb[2],base.rgb[3]}
  local source="terrain-average"
  -- Modern base maps can contain map-wide color patches; a global average
  -- would lose the brown mud strip beside a gray road. Use terrain-relative
  -- world XY, texture size in metres, wrap and Y flip (fixBaseCoords in the
  -- terrain shader). Legacy maps and oversized/unavailable maps use averages.
  local size=modern and tonumber(mat:getField("baseColorBaseTexSize",0))
  if base.bitmap and finite(size) and size>0 and terrain.getPosition then
    local origin=terrain:getPosition()
    local u=((pos.x-origin.x)/size)%1
    local v=(1-((pos.y-origin.y)/size)%1)%1
    local x,y=math.floor(u*base.w),math.floor(v*base.h)
    local color=ColorI(0,0,0,255)
    local sampled={0,0,0}
    for dy=-1,1 do for dx=-1,1 do
      if not base.bitmap:getColor((x+dx)%base.w,(y+dy)%base.h,color) then return nil end
      local channels={color.r,color.g,color.b}
      for i=1,3 do
        if not finite(channels[i]) or channels[i]<0 or channels[i]>255 then return nil end
        sampled[i]=sampled[i]+channels[i]/(9*255)
      end
    end end
    rgb=sampled;source="terrain-local"
  end
  if modern then
    for _,layer in ipairs({"Macro","Detail"}) do
      local strength=tonumber((mat:getField("baseColor"..layer.."Strength",0) or ""):match("^%s*([^%s]+)"))
      if finite(strength) and strength>0 then
        local detail=texture(mat:getField("baseColor"..layer.."Tex",0))
        if detail then for i=1,3 do rgb[i]=clamp(rgb[i]+(detail.rgb[i]*2-1)*clamp(strength)) end end
      end
    end
    -- The terrain shader combines these samples directly as linear albedo.
    -- Dynamic decals store the tint in a base-color map, sampled as sRGB by
    -- the vehicle material. Encode once or the deposited soil becomes black.
    for i=1,3 do
      local value=clamp(rgb[i])
      rgb[i]=value<=0.0031308 and 12.92*value or 1.055*value^(1/2.4)-0.055
    end
  end
  return rgb,source,mat:getField("internalName",0),basePath
end

function M.resolve(kind,pos)
  local default=fallback[kind]
  if not default then return nil end
  if pos and finite(pos.x) and finite(pos.y) and finite(pos.z) then
    local ok,rgb,source,material,path=pcall(terrainColor,kind,pos)
    if ok and rgb then return rgb,source,material,path end
  end
  return {default[1],default[2],default[3]},"fallback"
end

return M
