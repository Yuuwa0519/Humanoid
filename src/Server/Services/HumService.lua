-- Hum Service
-- Yuuwa0519
-- July 11, 2020

--Service
local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--Vars
local amount = 0
local base = ServerStorage.Base


local HumService = {Client = {}}

function HumService:SpawnHum()
    local char = base:Clone()
    local newHum = self.Modules.Humanoid.new(char)

    char.Parent = workspace
    char.HumanoidBase:SetNetworkOwner(nil)
    -- for _, part in pairs(char:GetDescendants()) do
    --     if (part:IsA("BasePart")) then
    --         PhysicsService:SetPartCollisionGroup(part, "Humanoids")
    --     end
    -- end
    
    amount = amount + 1
    self:FireAllClients("Spawned", amount)

    newHum:Activate()

    --Humanoid Vars
    local lastPos = newHum.Base.Position
    local lastJumpCheck = time()

    while (true) do
        
        -- newHum:MoveTo(Vector3.new(math.random(-100,100), math.random(0, 20), math.random(-100,100)),5)
        -- wait(5)

        local cDist, cPlr = math.huge, nil

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

        if (cPlr) then
            local  char = cPlr.Character

            if (char) then
                newHum:MoveTo(char.PrimaryPart.Position, 1)
            end
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
end

function HumService:Init()
    self:RegisterClientEvent("Spawn")
    self:RegisterClientEvent("Spawned")
end


return HumService