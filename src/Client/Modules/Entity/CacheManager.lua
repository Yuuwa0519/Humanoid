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

function CacheManager:AddCache(Entity, forceOverride)
    local isExist = Cache[Entity.Id]

    if (not isExist) then
        Cache[Entity.Id]  = Entity 
    elseif (forceOverride) then
        --Override Cache 
        self:RemoveCache(isExist.Id)
        Cache[Entity.Id] = Entity  
    -- else 
    --     warn("Cache Already Exist")   
    end
end

function CacheManager:RemoveCache(Id)
    --Remove Client Obj if Exist
    local Entity = Cache[Id] 

    if (Entity) then 
        Entity:Destroy()
        
        Cache[Id] = nil

        print(Cache[Id])
    else
        warn("No Entity With This Id Found: ", Id)
    end
end 

function CacheManager:GetCache(identifier)
    if (type(identifier) == "userdata") then
        for _, Entity in pairs(Cache) do 
            if (Entity.Actor == identifier) then 
                return Entity 
            end 
        end 

        return nil
    else
        return Cache[identifier]
    end
end

function CacheManager:CacheModel(model)
    model.Parent = CacheFolder
end

function CacheManager:CollectGarbage(camPos)
    local RemovedCacheCount = 0
    
    for _, Entity in pairs(Cache) do 
        if (not Entity.DoNotLoad) then 
            if (Entity.Actor) then
                if (Entity.Clothing) then 
                    local dist = (Entity.Actor.PrimaryPart.Position - camPos).Magnitude

                    if (dist > self.Modules.Entity.EntitySettings.CacheRemoveDist) then 
                        warn("Destroy Cause far Dist")
                        self:RemoveCache(Entity.Id)
                        RemovedCacheCount += 1
                    end
                else
                    warn("Destroy Cause no Clothing")
                    --Remove Cache if For Some Reason Clothing is Nil
                    self:RemoveCache(Entity.Id)
                    RemovedCacheCount += 1
                end
            else 
                warn("Destroy Cause No Actor")
                --Remove Cache if Actor is Nil
                self:RemoveCache(Entity.Id)
                RemovedCacheCount += 1
            end
        else 
            warn("Found Do Not Load Entity")
            self:RemoveCache(Entity.Id)
            RemovedCacheCount += 1
        end
    end

    if (RemovedCacheCount > 0) then
        warn("Collected " .. RemovedCacheCount .. " Cache!")
    end
end

return CacheManager