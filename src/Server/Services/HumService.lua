-- Hum Service
-- Yuuwa0519
-- July 11, 2020

--Service
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--Obj
local ClientRenderChars = ReplicatedStorage.EntityObjects
local ServerRenderHums = ServerStorage.EntityObjects
local base = ServerRenderHums.Base
local ClientRender = ClientRenderChars.Dinosaur

--Vars
local amount = 0

local HumService = {Client = {}}

function HumService:SpawnHum()
    local char = base:Clone()
    local entityClone = ClientRender
    local newHum = self.Shared.Humanoid.new(char)

    char.Parent = workspace.Characters
    char.HumanoidBase:SetNetworkOwner(nil)

    --Add to Entity 
    self.Services.EntityService:AddData(char, entityClone, {})
    -- for _, part in pairs(char:GetDescendants()) do
    --     if (part:IsA("BasePart")) then
    --         PhysicsService:SetPartCollisionGroup(part, "Humanoids")
    --     end
    -- end
    
    amount = amount + 1
    self:FireAllClients("Spawned", amount)

    --Humanoid Vars
    local lastPos = newHum.Base.Position
    local lastJumpCheck = time()

    while (true) do
        
        -- newHum:MoveTo(Vector3.new(math.random(-100,100), math.random(0, 20), math.random(-100,100)),5)
        -- wait(5)

        local cDist, cPlr = math.huge, nil
        local goalPos

        for _, plr in pairs(Players:GetPlayers()) do
            local char = plr.Character

            if (char) then
                local dist = (newHum.Base.Position - char.PrimaryPart.Position).Magnitude

                if (dist < cDist) then
                    cDist = dist
                    cPlr = plr
                end
            end
        end

        if (cPlr and newHum.ReachedTarget) then
            local  char = cPlr.Character

            if (char) then
                goalPos = char.PrimaryPart.Position
            end
        elseif (newHum.ReachedTarget) then
            local X = math.random(-50, 50)
            local Y = math.random(-5, 5)
            local Z = math.random(-50, 50)

            goalPos = newHum.Base.Position + Vector3.new(X, Y, Z)
        end 

        if (newHum.ReachedTarget) then 
            -- print("Moving to New Point")
            newHum:Deactivate()
            wait(5)
            newHum:Activate()
            newHum:MoveTo(goalPos)
        end

        if ((newHum.Base.Position - lastPos).Magnitude < 2 and time() - lastJumpCheck > 5) then
            newHum:Jump()

            lastJumpCheck = time()
        end

        lastPos = newHum.Base.Position
        wait(1)
    end
end


function HumService:Start()
    -- PhysicsService:CreateCollisionGroup("Humanoids")
    -- PhysicsService:CollisionGroupSetCollidable("Humanoids", "Humanoids", false)

    -- Players.PlayerAdded:Connect(function(plr)
    --     plr.CharacterAdded:Connect(function(char)
    --         for _, obj in pairs(char:GetDescendants()) do
    --             if (obj:IsA("BasePart")) then
    --                 PhysicsService:SetPartCollisionGroup(obj, "Humanoids")
    --             end
    --         end
    --     end)
    -- end)


    self:ConnectClientEvent("Spawn", function()
        self:SpawnHum()
    end)
    self:SpawnHum()
end

function HumService:Init()
    self:RegisterClientEvent("Spawn")
    self:RegisterClientEvent("Spawned")
end


return HumService