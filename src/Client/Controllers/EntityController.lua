-- Entity Controller
-- Yuuwa0519
-- July 28, 2020

--Services
local CollectionService = game:GetService("CollectionService")

--Obj 
local Camera = workspace.CurrentCamera

--Var 
local EntityService
local CacheManager
local LoopCount = 0 

local RenderedEntities = {}

--Setting 
local EntityRenderRadius = 50
local EntityRenderCount = 500
local EntityRenderRate = 1 
local BatchSize = 5
local Entity_CollectionTag = "CharacterEntityObject"


local EntityController = {}

function EntityController:RenderEntity(ServerObj)
    -- print("Render")
    local EntityData = CacheManager:GetCache(ServerObj)

    if (EntityData) then
        if (RenderedEntities[EntityData.Id]) then return end 

        EntityData:Mount()
        RenderedEntities[EntityData.Id] = EntityData
    else 
        print("First Creation!")
        EntityData = self.Services.EntityService:DownloadEntity(ServerObj)
        local newEntity = self.Modules.EntityManaging.EntityObject.new(EntityData.Id, EntityData.Actor, EntityData.Clothing:Clone(), EntityData.AnimArray)
        newEntity:Mount()
        print("Mounted")
        RenderedEntities[EntityData.Id] = newEntity
        CacheManager:AddCache(newEntity) --Initial Cache
    end
end

function EntityController:DerenderEntity(ServerObj)
    -- print("Derender")
    local EntityData 

    for _, entity in pairs(RenderedEntities) do
        if (entity.ServerObj == ServerObj) then 
            entity:UnMount()
            RenderedEntities[entity.Id] = nil
            CacheManager:AddCache(entity)
            return
        end
    end     
end 

function EntityController:RenderEntities()
    --Get all Entities
    local allEntities = CollectionService:GetTagged(Entity_CollectionTag)
    local orderedEntities = {}

    local CamPos = Camera.CFrame.Position

    for i, entity in pairs(allEntities) do
        local dist = (entity.PrimaryPart.Position - CamPos).Magnitude

        table.insert(orderedEntities, {entity, dist})
    end 

    table.sort(orderedEntities, function(a, b)
        return a[2] < b[2]
    end)
    -- print(#orderedEntities)
    -- print(#allEntities)
    -- print(self.Modules.Setting.RenderRadius)
    -- print(self.Modules.Setting.RenderCount)
    for i = 1, #allEntities do
        if (i <= self.Modules.Setting.RenderCount) then 
            if (orderedEntities[i][2] < self.Modules.Setting.RenderRadius) then 
                self:RenderEntity(orderedEntities[i][1])
            else
                self:DerenderEntity(orderedEntities[i][1])
            end 
        else 
            self:DerenderEntity(orderedEntities[i][1])
        end 

        if (i % 20 == 0) then 
            wait() 
        end 
    end 

    LoopCount += 1 
    if (LoopCount % 10 == 0) then 
        CacheManager:CollectGarbage(Camera.CFrame.Position)
    end 
end 

function EntityController:Start()
    EntityService = self.Services.EntityService
    CacheManager = self.Modules.EntityManaging.CacheManager
    
    while (true) do
        self:RenderEntities()
        wait(EntityRenderRate)
    end 
end

return EntityController