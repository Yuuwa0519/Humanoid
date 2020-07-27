-- Entity Client
-- Yuuwa0519
-- July 26, 2020

--Obj 
local Camera = workspace.CurrentCamera
local CharacterFolder = workspace:WaitForChild("Characters")

--Var 
-- local MustRender = {}
local CurrentRender = {}

--Setting 
local RenderRadius = 100

local Debug = false

local EntityClient = {}

local function debugPrint(isWarn, ...)
    if (not Debug) then return end 

	if (isWarn) then
		warn(...)
	else 
		print(...) 
	end
end 

-- function EntityClient:AddMustRender(Obj)
--     table.insert(MustRender, Obj)
-- end 

function EntityClient:Render(Obj)
    if (#CurrentRender >= self.Modules.Setting.RenderCount) then return end 

    local EntityData = self.Services.EntityManager:GetEntityData(Obj)
    local PreRendered = Obj:FindFirstChild("EntityRenderObj")

    if (PreRendered) then 
        debugPrint(false, "Already Rendered: ", Obj.Name)
        return 
    end 

    if (EntityData) then
        local PrimaryPart = Obj.PrimaryPart

        if (PrimaryPart) then 
            local Weld = Instance.new("WeldConstraint")
            local ClonedCharacter = EntityData.ClientObj:Clone()

            ClonedCharacter:SetPrimaryPartCFrame(PrimaryPart.CFrame:ToWorldSpace(EntityData.C0))
            ClonedCharacter.Name = "EntityRenderObj"
            ClonedCharacter.Parent = Obj

            -- ClonedCharacter.PrimaryPart:SetNetworkOwner(nil)

            Weld.Part0 = PrimaryPart 
            Weld.Part1 = ClonedCharacter.PrimaryPart 
            -- Weld.C0 = EntityData.C0 
            Weld.Name = "EntityWeld"
            Weld.Parent = PrimaryPart

            table.insert(CurrentRender, Obj)
            -- debugPrint(false, CurrentRender)
        else 
            debugPrint(true, "Obj Doesn't Have PrimaryPart", Obj:GetFullName())
        end
    else
        debugPrint(true, "Found Untracked Entity: ", Obj:GetFullName())
    end
end 

function EntityClient:Derender(Obj)
    if (Obj) then 
        for index, v in pairs(CurrentRender) do
            if (v == Obj[2]) then
                CurrentRender[index] = nil 
                break 
            end 
        end 

        local RenderedEntity = Obj[2]:FindFirstChild("EntityRenderObj")
        local RenderedWeld = Obj[2].PrimaryPart:FindFirstChild("EntityWeld")

        if (RenderedEntity) then 
            RenderedEntity:Destroy()
        end 

        if (RenderedWeld) then
            RenderedWeld:Destroy()
        end 

        -- debugPrint(false, "Derendered", Obj.Name)
        -- debugPrint(false, CurrentRender)
    else 
        debugPrint(true, "NO Obj to Derender. Setting to Nil!")
    end 

    CurrentRender[Obj[1]] = nil;
end 

function EntityClient:RenderEntities()
    local CameraCF = Camera.CFrame
    local CameraPos = CameraCF.Position

    local UnloadingObjs = {}
    local LoadingObjs = {}

    --Check for Unloading
    for index, Obj in pairs(CurrentRender) do 
        if (Obj) then
            if (true) then --Check for Must Render Later
                local dist = (Obj.PrimaryPart.Position - CameraPos).Magnitude 

                if (dist > RenderRadius) then 
                    table.insert(UnloadingObjs, {index, Obj})
                    -- debugPrint(false, "Added To Unrender: ", Obj.Name)
                else 
                    debugPrint(false, dist)
                end
            end
        else 
            table.insert(UnloadingObjs, {index, Obj})
        end 
    end 

    --Checking Loading
    for _, Obj in pairs(CharacterFolder:GetChildren()) do 
        local dist = (Obj.PrimaryPart.Position - CameraPos).Magnitude 

        if (dist < RenderRadius) then 
            if (not table.find(CurrentRender, Obj)) then 
                local standing = 1
                for index, v in pairs(LoadingObjs) do
                    if (v[2] > dist) then 
                        standing = index 
                        break
                    end 
                end 

                table.insert(LoadingObjs, standing, {Obj, dist})
                -- debugPrint(false, "Added to Render", Obj.Name)
            else 
                -- debugPrint(false, "Already Rendered", Obj.Name)
            end 
        end
    end 

    debug.profilebegin("EntityRender")
    --Start Loading / Unloading 
    for _, Obj in pairs(UnloadingObjs) do 
        self:Derender(Obj)
    end 

    for _, Obj in pairs(LoadingObjs) do 
       self:Render(Obj[1])
    end 
    debug.profileend()

    -- for _, Obj in pairs(MustRender) do 
    --     self:Render(Obj)
    -- end 
end

function EntityClient:Start()
    while (true) do 
        self:RenderEntities()
        wait(2)
    end
end


function EntityClient:Init()
	
end


return EntityClient