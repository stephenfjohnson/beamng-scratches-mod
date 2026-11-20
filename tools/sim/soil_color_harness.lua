-- Terrain lookup and texture failures must never break the contact pipeline.
local savedTerrain,savedBitmap,savedColor=core_terrain,GBitmap,ColorI
local n=0
local function check(ok,msg) assert(ok,msg);n=n+1 end
local function linear(c) return c<=0.04045 and c/12.92 or ((c+0.055)/1.055)^2.4 end
local fields={groundmodelName="MUD",internalName="Test mud",baseColorBaseTex="base",
  baseColorMacroTex="macro",baseColorMacroStrength="0.2 0.8",
  baseColorDetailTex="detail",baseColorDetailStrength="0.25 0.5"}
local textures={base={128,100,80},macro={128,128,128},detail={180,110,90}}
local loads,pixels=0,0
local bitmapWidth,bitmapHeight=16,16
local spatial=false
local height,idx=0,2
local mat={getField=function(_,name) return fields[name] or "" end}
local terrain={getHeight=function() return height end,getMaterialIdxWs=function() return idx end,
  getMaterial=function() return mat end}
core_terrain={getTerrain=function() return terrain end}
ColorI=function() return {} end
GBitmap=function()
  local data,texturePath
  return {loadFile=function(_,path) loads=loads+1;texturePath=path;data=textures[path];return data~=nil end,
    getWidth=function() return bitmapWidth end,getHeight=function() return bitmapHeight end,
    getColor=function(_,x,y,c)
      assert(x>=0 and x<bitmapWidth and y>=0 and y<bitmapHeight)
      pixels=pixels+1;c.r=data[1];c.g=data[2];c.b=data[3]
      if spatial and texturePath=="base" then c.r=x*10;c.g=y*10;c.b=30 end
      return true
    end}
end
-- The terrain maths below is checked without the wet-mud tone on top of it.
local function fresh() local m=dofile("lua/ge/extensions/scratches/soilColor.lua");m.wetTone={};return m end
do
  local wetModule=dofile("lua/ge/extensions/scratches/soilColor.lua")
  local dry=fresh().resolve("mud",{x=0,y=0,z=0.3})
  local wet=wetModule.resolve("mud",{x=0,y=0,z=0.3})
  check(wet[1]<dry[1]*0.75 and wet[3]<dry[3]*0.62 and wet[3]/wet[1]<dry[3]/dry[1],
    "terrain-sampled mud lands darker and browner than the dry ground")
  loads,pixels=0,0
end
local color=fresh()
local pos={x=0,y=0,z=0.3}
local rgb,source,name,path=color.resolve("mud",pos)
check(source=="terrain-average" and name=="Test mud" and path=="base","uses matching contacted terrain")
check(math.abs(linear(rgb[1])-(128/255+(256/255-1)*.2+(360/255-1)*.25))<1e-9,
  "near strengths combine base, macro and detail averages in terrain shader order")
check(loads==3 and pixels==192,"each texture uses a bounded 8 by 8 sample grid")
rgb[1]=99
local again=color.resolve("mud",pos)
check(again[1]<1 and loads==3 and pixels==192,"cache reuses RGB values without exposing mutable cache entries")
fields.baseColorBaseTexSize="16"
terrain.getPosition=function() return {x=100,y=200,z=0} end
pos.x=104;pos.y=204;spatial=true
local localRgb,localSource=color.resolve("mud",pos)
check(localSource=="terrain-local" and math.abs(linear(localRgb[1])-(40/255+(256/255-1)*.2+(360/255-1)*.25))<1e-9,
  "local terrain offset selects the base color under the contact")
check(math.abs(linear(localRgb[2])-(120/255+(256/255-1)*.2+(220/255-1)*.25))<1e-9,
  "terrain base UV flips Y")
pos.x=88;pos.y=188
local wrapped=color.resolve("mud",pos)
check(math.abs(wrapped[1]-localRgb[1])<1e-9 and math.abs(wrapped[2]-localRgb[2])<1e-9,
  "negative and repeated coordinates wrap consistently")
check(loads==3 and pixels==210,"local colors reuse the retained bitmap with nine reads per accepted deposit")
spatial=false;pos.x=0;pos.y=0
bitmapWidth=4096;bitmapHeight=4096
local huge=fresh()
check(select(2,huge.resolve("mud",pos))=="terrain-average","oversized base uses mean without retaining a large bitmap")
bitmapWidth=16;bitmapHeight=16
local beforeMapLoads=loads
local otherTerrain={getHeight=terrain.getHeight,getMaterialIdxWs=terrain.getMaterialIdxWs,getMaterial=terrain.getMaterial}
core_terrain.getTerrain=function() return otherTerrain end
color.resolve("mud",pos)
check(loads==beforeMapLoads+3,"terrain change invalidates the texture cache")
core_terrain.getTerrain=function() return terrain end
terrain.getPosition=nil;fields.baseColorBaseTexSize=nil
color.resolve("mud",pos)
local _,wrong=color.resolve("snow",pos)
local beforeWrong=loads
color.resolve("snow",pos)
check(wrong=="fallback" and loads==beforeWrong,"collision kind mismatch does not borrow terrain tint")
pos.z=3
check(select(2,color.resolve("mud",pos))=="fallback","mesh high above terrain uses fallback")
pos.z=0.3;idx=-1
check(select(2,color.resolve("mud",pos))=="fallback","out of terrain bounds uses fallback")
idx=2;height=0/0
check(select(2,color.resolve("mud",pos))=="fallback","nonfinite terrain height rejected")
height=0;fields.baseColorBaseTex="missing"
check(select(2,color.resolve("mud",pos))=="fallback","unreadable base texture uses fallback")
local failedLoads=loads
color.resolve("mud",pos)
check(loads==failedLoads,"failed loads are cached")
fields.baseColorBaseTex="";fields.diffuseMap="base"
local legacy,legacySource=color.resolve("mud",pos)
check(legacySource=="terrain-average" and math.abs(legacy[1]-128/255)<1e-9,"legacy diffuse texture supported without modern offsets")
fields.diffuseMap="bad";textures.bad={0/0,50,50}
check(select(2,color.resolve("mud",pos))=="fallback","invalid texture channels rejected")
terrain.getMaterial=function() error("unsupported API") end
check(select(2,color.resolve("mud",pos))=="fallback","engine method failure contained")
terrain.getMaterial=function() return mat end
core_terrain=nil
check(select(2,color.resolve("mud",pos))=="fallback","no terrain extension supported")
core_terrain={getTerrain=function() return terrain end}
GBitmap=nil
check(select(2,color.resolve("mud",pos))=="fallback","no bitmap API supported")
check(color.resolve("unknown",pos)==nil,"unknown soil kind rejected")
check(select(2,color.resolve("mud",{x=0/0,y=0,z=0}))=="fallback","invalid world position contained")
-- A cache full of missing paths cannot cause unlimited disk reads.
local attempts=0
GBitmap=function() return {loadFile=function() attempts=attempts+1;return false end} end
color=fresh()
for i=1,40 do fields.diffuseMap="missing"..i;color.resolve("mud",pos) end
check(attempts==32,"cache and first-use texture reads are bounded")
core_terrain,GBitmap,ColorI=savedTerrain,savedBitmap,savedColor
return n
