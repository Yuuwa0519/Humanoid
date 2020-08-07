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

function EntityController:GetEntityStats()
    return #RenderedEntities
end

function EntityController:RenderEntities(Actors)
    local renderStart = time()
    for _, Actor in pairs(Actors) do 
        local Entity = CacheManager:GetCache(Actor)

        if (Entity) then
            --Reuse Cache
            if (not Entity.DoNotLoad) then
                Entity:WearCloth()
                table.insert(RenderedEntities, Entity)
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
            else
                warn("Untracked Entity: ", Actor:GetFullName())
            end
        end 
    end
    print("Render Duration", time() - renderStart)
end

function EntityController:DerenderEntities(Actors)
    local renderStart = time()
    for _, Actor in pairs(Actors) do 
        --Derender, Cache
        local Entity = CacheManager:GetCache(Actor)

        if (Entity) then 
            Entity:TakeoffCloth()
            CacheManager:AddCache(Entity)
            
            for i, candidate in pairs(RenderedEntities) do
                if (candidate.Id == Entity.Id) then 
                    table.remove(RenderedEntities, i)
                    break
                end
            end
        end
    end
    print("Derender Duration", time() - renderStart)
end 

function EntityController:GetEntitiesToRender()
    local getStart = time()
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
    local Render = {}
    local Derender = {}
    local TotalRenders = 0

    for _, Array in pairs(reorderedActors) do
        if (Array[2] <= EntitySettings.MaxRenderDist) then 
            if ((TotalRenders) <= EntitySettings.MaxRenderCount) then
                local isExist = false 

                for _, Entity in pairs(RenderedEntities) do 
                    if (Entity.Actor == Array[1]) then 
                        isExist = true
                        break 
                    end
                end

                if (not isExist) then
                    table.insert(Render, Array[1])
                -- else
                --     warn("Already Render")
                end
                TotalRenders += 1
            else 
                -- warn("MaxRender")
                table.insert(Derender, Array[1])
            end 
        else 
            -- warn("Too Far")
            table.insert(Derender, Array[1])
        end
    end 

    -- self.Shared.TableUtil.Print(Render, "Render", false)
    -- self.Shared.TableUtil.Print(Derender, "Derender", false)
    print("Render Get Duration: ", time() - getStart)
    return Render, Derender
end 

function EntityController:Start()
    CacheManager = self.Modules.Entity.CacheManager
    EntitySettings = self.Modules.Entity.EntitySettings
    EntityObject = self.Modules.Entity.EntityObject
    EntityService = self.Services.EntityService

    local loopCount = 1

    while (true) do
        warn("------------------------------------------------------------")
        local renderStart = time()
        local Render, Derender = self:GetEntitiesToRender()
        
        self:DerenderEntities(Derender)
        self:RenderEntities(Render)

        loopCount += 1 
        if (loopCount % 10) == 0 then 
            CacheManager:CollectGarbage(Camera.CFrame.Position)
        end
        print("Total Render Duration: ", time() - renderStart)
        wait(EntitySettings.RenderRate)
    end 
end

return EntityController