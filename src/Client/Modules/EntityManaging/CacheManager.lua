-- Cache Manager
-- Yuuwa0519
-- July 28, 2020

local EntityCache = {}

local CacheManager = {}

function CacheManager:GetCache(ServerObj)
    local cache 

    for _, entity in pairs(EntityCache) do 
        if (entity.ServerObj == ServerObj) then
            return entity
        end
    end 
end 

function CacheManager:AddCache(Obj)
    if (not EntityCache[Obj.Id]) then
        EntityCache[Obj.Id] = Obj
    -- else 
    --     warn("There Is Cache In ID", Obj.Id)
    end 
end 

function CacheManager:RemoveCache(Id)
    if (EntityCache[Id]) then 
        EntityCache[Id]:Destroy()
    end

    EntityCache[Id] = EntityCache[#EntityCache]
    EntityCache[#EntityCache] = nil

    warn("Removed Cache " .. Id)
end 

function CacheManager:CollectGarbage(camPos)
    print("Cache:CollectGarbage()")
    for _, entity in pairs(EntityCache) do 
        if (not entity.ServerObj) then
            self:RemoveCache(entity.Id)
        elseif (entity.ServerObj.PrimaryPart.Position - camPos).Magnitude > 200 then 
            self:RemoveCache(entity.Id)
        end
    end 
end 

return CacheManager