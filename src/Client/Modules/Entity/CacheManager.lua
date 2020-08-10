-- Cache Manager
-- Yuuwa0519
-- July 30, 2020

--Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Obj 
local CacheFolder = Instance.new("Folder")
CacheFolder.Name = "CacheFolder"
CacheFolder.Parent = ReplicatedStorage

--Var
local Cache = {}

local CacheManager = {}

function CacheManager:AddCache(Entity)
    local isExist = Cache[Entity.Id]
    
    if (not isExist) then
        Cache[Entity.Id]  = Entity 
    end
end

function CacheManager:RemoveCache(Id)
    --Remove Client Obj if Exist
    local Entity = Cache[Id] 

    if (Entity) then 
        Entity:Destroy()
        
        Cache[Id] = nil
    else
        warn("No Entity With This Id Found: ", Id)
    end
end 

function CacheManager:GetCache(Id)
    return Cache[Id]
end

function CacheManager:CacheModel(model)
    if (model) then
        model.Parent = CacheFolder
    else 
        warn("Called CacheModel on Invalid Model!")
    end
    -- print("CacheFolder Count", #CacheFolder:GetChildren())
end

function CacheManager:CollectGarbage(camPos)
    local RemovedCacheId = {}
    local trackedCache = {}
    
    for _, Entity in pairs(Cache) do 
        local Id = Entity.Id

        if (not Entity.DoNotLoad) then 
            if (Entity.Actor and Entity.Actor.PrimaryPart) then
                if (Entity.Clothing and Entity.Clothing.PrimaryPart) then 
                    local dist = (Entity.Actor.PrimaryPart.Position - camPos).Magnitude

                    if (dist > self.Modules.Entity.EntitySettings.CacheRemoveDist) then 
                        self:RemoveCache(Entity.Id)
                        table.insert(RemovedCacheId, Id)
                    end
                else
                    warn("Destroy Cause no Clothing")
                    --Remove Cache if For Some Reason Clothing is Nil
                    self:RemoveCache(Entity.Id)
                    table.insert(RemovedCacheId, Id)
                end
            else 
                warn("Destroy Cause No Actor")
                --Remove Cache if Actor is Nil
                self:RemoveCache(Entity.Id)
                table.insert(RemovedCacheId, Id)
            end
        else 
            self:RemoveCache(Entity.Id)
            table.insert(RemovedCacheId, Id)
        end
    end

    if (#RemovedCacheId > 0) then
        warn("Collected " .. #RemovedCacheId .. " Cache!")
    end

    return RemovedCacheId
end

return CacheManager