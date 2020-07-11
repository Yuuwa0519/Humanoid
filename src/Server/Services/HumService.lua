-- Hum Service
-- Username
-- July 11, 2020

--Service
local ServerStorage = game:GetService("ServerStorage")
local PhysicsService = game:GetService("PhysicsService")

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
            newHum:MoveTo(Vector3.new(math.random(-100,100), math.random(0, 20), math.random(-100,100)),5)
            wait(5)
        end
    end)
end

function HumService:Init()
    self:RegisterClientEvent("Spawn")
    self:RegisterClientEvent("Spawned")
end


return HumService