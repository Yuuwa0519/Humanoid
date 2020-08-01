-- Entity Controller
-- Yuuwa0519
-- July 29, 2020

--Services 
local CollectionService = game:GetService("CollectionService")

--Modules 
local EntityService 

local CacheManager
local EntityObject
local EntitySettings

--Obj 
local Camera = workspace.CurrentCamera

--Var 
local RenderedEntities = {}

local EntityController = {}

function EntityController:RenderEntities(Actors)
    for _, Actor in pairs(Actors) do 
        local Entity = CacheManager:GetCache(Actor)

        if (Entity) then
            --Reuse Cache
            if (not Entity.DoNotLoad) then
                Entity:WearCloth()
            else
                warn("Entity Still Remaining in Cache Even Though Do Not Load!")
            end
        else
            --First Time Creating Enti
            local EntityData = EntityService:DownloadEntity(Actor)

            if (EntityData) then 
                local newEntity = EntityObject.new(EntityData)
                newEntity:WearCloth()

                table.insert(RenderedEntities, newEntity)
                CacheManager:AddCache(newEntity)
                print("Initial Creation", newEntity.Id)
            else
                warn("Untracked Entity: ", Actor.PrimaryPart:GetFullName())
            end
        end 
    end
end

function EntityController:DerenderEntities(Entities)
    for _, Entity in pairs(Entities) do 
        --Derender, Cache
        Entity:TakeoffCloth()
        CacheManager:AddCache(Entity)
    end
end 

function EntityController:GetEntitiesToRender()
    local CamPos = Camera.CFrame.Position
    local allEntityActors = CollectionService:GetTagged(EntitySettings.EntityTag)
    local reorderedActors = {}

    for _, Actor in pairs(allEntityActors) do
        local dist = (Actor.PrimaryPart.Position - CamPos).Magnitude

        table.insert(reorderedActors, {Actor, dist})
    end 

    table.sort(reorderedActors, function(a, b)
        return (a[2] < b[2])
    end)

    --Separate it into Render and Derender Group
    local Render = {}--self.Shared.TableUtil.CopyShallow(ForceRenderEntities)
    local Derender = {}--self.Shared.TableUtil.CopyShallow(ForceDerenderEntities)

    for _, Array in pairs(reorderedActors) do
        if ((#Render + #RenderedEntities) < EntitySettings.MaxRenderCount) then 
            if (Array[2] <= EntitySettings.MaxRenderDist) then
                table.insert(Render, Array[1])
            end 
        else 
            --If Rendering Objects is Over MaxRenderCount, Break out of Loop
            break
        end 
    end 

    for i, Entity in pairs(RenderedEntities) do 
        local Actor = Entity.Actor 
        local dist = (Actor.PrimaryPart.Position - CamPos).Magnitude

        if (dist > EntitySettings.MaxRenderDist) then 
            table.insert(Derender, Entity)
            table.remove(RenderedEntities, i)
        end
    end

    return Render, Derender
end 

function EntityController:Start()
    CacheManager = self.Modules.Entity.CacheManager
    EntitySettings = self.Modules.Entity.EntitySettings
    EntityObject = self.Modules.Entity.EntityObject
    EntityService = self.Services.EntityService

    local loopCount = 1

    while (true) do
        local Render, Derender = self:GetEntitiesToRender()

        self:DerenderEntities(Derender)
        self:RenderEntities(Render)

        loopCount += 1 
        if (loopCount % 10) == 0 then 
            CacheManager:CollectGarbage(Camera.CFrame.Position)
        end
        
        wait(EntitySettings.RenderRate)
    end 
end

function EntityController:Init()

end


return EntityController