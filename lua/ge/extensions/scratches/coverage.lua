-- Optional representative-coverage policy. Geometric containment is a proxy,
-- not pixel equivalence: repeated brush variants inside a stronger footprint
-- are intentionally represented by that footprint. Soil is never admitted.
local M = {}
function M.new(clock)
  local self={buckets={},history={},required={},delivered={},nextId=0,
    stats={requests=0,representatives=0,mergedQueued=0,mergedBaked=0,
      staleMerged=0,completedRequests=0,lostRequests=0,failedRepresentatives=0,
      requiredCells=0,deliveredCells=0,trackingOverflow=0,historyEvicted=0}}
  local CELL, BUCKET, LIMIT = 0.08, 0.25, 8192
  local function bucket(x,y,z,f) return f..':'..x..':'..y..':'..z end
  local function cells(s,f)
    local p,n=s.localPos,s.localNormal
    local a,b,face
    if math.abs(n.z)>=math.abs(n.x) and math.abs(n.z)>=math.abs(n.y) then
      a,b,face=p.x,p.y,n.z>=0 and 'z+' or 'z-'
    elseif math.abs(n.x)>=math.abs(n.y) then a,b,face=p.y,p.z,n.x>=0 and 'x+' or 'x-'
    else a,b,face=p.x,p.z,n.y>=0 and 'y+' or 'y-' end
    local keys={}
    -- Footprint proxy: circle at the authored half-size on the dominant plane.
    for x=math.floor((a-s.scale)/CELL),math.floor((a+s.scale)/CELL) do
      for y=math.floor((b-s.scale)/CELL),math.floor((b+s.scale)/CELL) do
        local dx,dy=(x+.5)*CELL-a,(y+.5)*CELL-b
        if dx*dx+dy*dy<=(s.scale+CELL*.5)^2 then
          keys[#keys+1]=f..':'..face..':'..x..':'..y
        end
      end
    end
    return keys
  end
  local function requireKeys(keys)
    for _,k in ipairs(keys) do
      if not self.required[k] then
        if self.stats.requiredCells<65536 then self.required[k]=true;self.stats.requiredCells=self.stats.requiredCells+1
        else self.stats.trackingOverflow=self.stats.trackingOverflow+1 end
      end
    end
  end
  local function deliverKeys(keys)
    for _,k in ipairs(keys) do
      if self.required[k] and not self.delivered[k] then
        self.delivered[k]=true;self.stats.deliveredCells=self.stats.deliveredCells+1
      end
    end
  end
  function self:admit(s)
    assert(not s.soil,'soil must bypass representative damage policy')
    self.stats.requests=self.stats.requests+1
    local family=(s.brush:match('m4_([a-z]+)') or s.brush)..':'..math.floor((s.severity or 0)*3)..':'..(s.styleKey or 'procedural')
    local keys=cells(s,family);requireKeys(keys)
    local p,n=s.localPos,s.localNormal
    local bx,by,bz=math.floor(p.x/BUCKET),math.floor(p.y/BUCKET),math.floor(p.z/BUCKET)
    for x=bx-1,bx+1 do for y=by-1,by+1 do for z=bz-1,bz+1 do
      for _,r in ipairs(self.buckets[bucket(x,y,z,family)] or {}) do
        local dx,dy,dz=p.x-r.p.x,p.y-r.p.y,p.z-r.p.z
        if r.state~='failed' and r.n:dot(n)>=.98 and
          math.sqrt(dx*dx+dy*dy+dz*dz)+s.scale<=r.radius then
          r.count=r.count+1
          if r.state=='baked' then
            self.stats.mergedBaked=self.stats.mergedBaked+1
            self.stats.completedRequests=self.stats.completedRequests+1
            deliverKeys(keys)
          else
            self.stats.mergedQueued=self.stats.mergedQueued+1
            if clock()-r.born>.5 then self.stats.staleMerged=self.stats.staleMerged+1 end
            for _,k in ipairs(keys) do if not r.keySet[k] then r.keys[#r.keys+1]=k;r.keySet[k]=true end end
          end
          return r,false
        end
      end
    end end end
    local key=bucket(bx,by,bz,family)
    local r={p=p,n=n,radius=s.scale,born=s.queuedAt,count=1,state='queued',keys=keys,keySet={},bucket=key}
    for _,k in ipairs(keys) do r.keySet[k]=true end
    self.nextId=self.nextId+1;r.id=self.nextId
    self.history[#self.history+1]=r
    self.buckets[key]=self.buckets[key] or {};table.insert(self.buckets[key],r)
    if #self.history>LIMIT then
      local old=table.remove(self.history,1);local b=self.buckets[old.bucket]
      for i,v in ipairs(b) do if v==old then table.remove(b,i);break end end
      if #b==0 then self.buckets[old.bucket]=nil end
      self.stats.historyEvicted=self.stats.historyEvicted+1
    end
    self.stats.representatives=self.stats.representatives+1
    return r,true
  end
  function self:complete(r)
    if not r or r.state~='queued' then return end
    r.state='baked';self.stats.completedRequests=self.stats.completedRequests+r.count
    deliverKeys(r.keys);r.keys={};r.keySet={}
  end
  function self:fail(r)
    if not r or r.state~='queued' then return end
    r.state='failed';self.stats.lostRequests=self.stats.lostRequests+r.count
    self.stats.failedRepresentatives=self.stats.failedRepresentatives+1;r.keys={};r.keySet={}
  end
  function self:snapshot()
    local out={};for k,v in pairs(self.stats) do out[k]=v end
    out.pendingRequests=out.requests-out.completedRequests-out.lostRequests
    out.unrepresentedCells=out.requiredCells-out.deliveredCells
    out.cachedRepresentatives=#self.history
    return out
  end
  return self
end
return M
