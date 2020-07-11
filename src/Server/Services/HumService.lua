-- Hum Service
-- Yuuwa0519
-- July 11, 2020

--Service
local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local base = ServerStorage.Base


local HumService = {Client = {}}


function HumService:Start()
    local amount = 0 

    PhysicsService:CreateCollisionGroup("Humanoids")
    PhysicsService:CollisionGroupSetCollidable("Humanoids", "Humanoids", false)


    self:ConnectClientEvent("Spawn", function()
        local char = base:Clone()
        local newHum = self.Modules.Humanoid.new(char)

        char.Parent = workspace
        char.HumanoidBase:SetNetworkOwner(nil)
        for _, part in pairs(char:GetDescendants()) do
            if (part:IsA("BasePart")) then
                PhysicsService:SetPartCollisionGroup(part, "Humanoids")
            end
        end
        
        amount = amount + 1
        self:FireAllClients("Spawned", amount)

        newHum:Activate()

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
                    wait(1)
                end
            end

            RunService.Heartbeat:Wait()
        end
    end)
end

function HumService:Init()
    self:RegisterClientEvent("Spawn")
    self:RegisterClientEvent("Spawned")
end


return HumService