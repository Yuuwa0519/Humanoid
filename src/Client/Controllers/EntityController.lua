-- Entity Controller
-- Yuuwa0519
-- July 29, 2020

--Services 

--Modules 
local EntityService 

local CacheManager
local EntityObject
local EntitySettings

--Obj 
local Camera = workspace.CurrentCamera

--Var 
local RenderedEntities = {}
local ForceRender = {}

local isEntityReady = false
local EntityReady

--Settings 
local DebugMode = false 

local EntityController = {}

local function debugPrint(isWarn, ...)
    if (not DebugMode) then return end
    if (isWarn) then 
        warn(...)
    else 
        print(...)
    end
end

function EntityController:GetEntityStats()
    return #RenderedEntities
end

function EntityController:AddForceRender(Id)
    print("New Force Render", Id)
    table.insert(ForceRender, Id)
end

function EntityController:RemoveForceRender(Id)
    local isExist = false
    for i, v in pairs(ForceRender) do 
        if (v == Id) then
            self.Shared.TableUtil.FastRemove(ForceRender, i)
            isExist = true
            print("Removed Force Render", Id)
            break
        end
    end

    if (not isExist) then 
        warn("Attempt to Remove Non-Existant Entity Id from Force Render", Id)
    end
end

function EntityController:RenderEntities(Arrays)
    local renderStart = time()
    local done = {}

    for i, Array in pairs(Arrays) do 
        local CEntity = CacheManager:GetCache(Array.Id)

        if (CEntity) then
            --Reuse Cache
            --print("Reuse Cache")
            CEntity:WearCloth()
            table.insert(RenderedEntities, CEntity.Id)
            table.insert(done, Array.Id)
        else
            self.Shared.Thread.Spawn(function()
                --First Time Creating Entity
                local CEntityData = EntityService:DownloadEntity(Array.Id)
                
                if (CEntityData) then 
                    local newEntity = EntityObject.new(CEntityData)
                    newEntity:WearCloth()

                    table.insert(RenderedEntities, newEntity.Id)
                    CacheManager:AddCache(newEntity)

                    table.insert(done, Array.Id)
                else
                    warn("Untracked Entity: ", Array.Id)
                end
            end)
        end
    end

    repeat 
        wait(.5)
    until #done == #Arrays

    print("Render Duration", time() - renderStart)
end

function EntityController:DerenderEntities(Arrays)
    for _, Array in pairs(Arrays) do 
        --Derender, Cache
        local CEntity = CacheManager:GetCache(Array.Id)

        if (CEntity) then 
            CEntity:TakeoffCloth()
        end

        local candidate = nil 

        for i, id in pairs(RenderedEntities) do 
            if (id == Array.Id) then 
                candidate = i
            end 
        end

        if (candidate) then 
            self.Shared.TableUtil.FastRemove(RenderedEntities, candidate)
        end
    end
end 

function EntityController:GetEntitiesToRender()
    local CamCF = Camera.CFrame
    --Just for test, use torso pos
    do
        local char = self.Player.Character 

        if (char) then
            if (char.PrimaryPart) then 
                CamCF = char:GetPrimaryPartCFrame()
            end 
        end
    end
    local CamPos = CamCF.Position
    
    local allEntities = EntityService:GetEntities(CamPos, EntitySettings.MaxRenderDist)
    local reorderedEntities = {}

    for _, Array in pairs(allEntities) do
        local dist = (Array.Pos - CamPos).Magnitude

        table.insert(reorderedEntities, {Array, dist})
    end 

    table.sort(reorderedEntities, function(a, b)
        return a[2] < b[2]   
    end)

    --Separate it into Render and Derender Group
    local Render = {}
    local Derender = {}
    local TotalRenders = 0

    --[[
        --Note Cause I keep Forgetting and Debug For Nothing
        Initially, Total Renders is 0. 
        Then, On Render Iteration, It will Count Even if its Already in Rendered Entities, 
        Which WIll In the end account for both newly rendered and already rendered entities. 


    ]]

    for i, Id in pairs(RenderedEntities) do 
        local isExist = false 
        for _, Array in pairs(reorderedEntities) do 
            if (Array[1].Id == Id) then 
                isExist = true
                break
            end
        end

        if (not isExist) then 
            table.insert(Derender, {Id = Id})
        end
    end

    for i, Array in pairs(reorderedEntities) do
        local canRender = TotalRenders <= EntitySettings.MaxRenderCount 

        if (canRender) then
            local isExist = false 

            for _, v in pairs(RenderedEntities) do 
                if (v == Array[1].Id) then 
                    isExist = true
                    break 
                end
            end
            if (not isExist) then
                table.insert(Render, {Id = Array[1].Id})
            end
            TotalRenders += 1
        else 
            -- warn("MaxRender")
            local isExist = false 

            for _, v in pairs(Derender) do 
                if (v.Id == Array[1].Id) then 
                    warn("Contradictory With Derender! Derendering Twice")
                    isExist = true
                    break
                end
            end

            if (not isExist) then
                table.insert(Derender, {Id = Array[1].Id})
            end
        end
    end 

    for _, Id in pairs(ForceRender) do 
        local isExist = false 

        for _, v in pairs(RenderedEntities) do 
            if (v == Id) then 
                isExist = true
                break 
            end
        end
        if (not isExist) then
            table.insert(Render, {Id = Id})
        end
        TotalRenders += 1
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
            local collectedIds = CacheManager:CollectGarbage(Camera.CFrame.Position)
            for _, Id in pairs(collectedIds) do 
                local isExist = false 
                for i, RenderedId in pairs(RenderedEntities) do 
                    if (Id == RenderedId) then 
                        self.Shared.TableUtil.FastRemove(RenderedEntities, Id)
                        break
                    end
                end
            end
        end

        wait(EntitySettings.RenderRate)
    end 
end

return EntityController