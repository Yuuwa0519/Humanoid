-- Base Creature
-- Yuuwa0519
-- August 1, 2020

--Service 
local ServerStorage = game:GetService("ServerStorage")
local EntityService

--Obj
local EntityObject = ServerStorage.EntityObjects
local HumBase = EntityObject.Base

local BaseCreature = {}
BaseCreature.__index = BaseCreature 

local function mergeTable(t1, t2)
    for index, value in pairs(t2) do 
        t1[index] = value
    end
    return t1
end

function BaseCreature.new(Clothing, AnimDict, EntityOffset, baseArray)
    local Actor = HumBase:Clone()
    local EntityId = EntityService:AddEntity(Actor, Clothing, AnimDict, EntityOffset)

    local creatureArray = {
        EntityId = EntityId;
        Running = false;
        Actor = Actor;

        Humanoid = BaseCreature.Shared.Humanoid.new(Actor, nil, baseArray.HumanoidSettings);
    }
    local merged = mergeTable(creatureArray, (baseArray or {}))

    local self = setmetatable(merged, BaseCreature)

    return self
end

function BaseCreature:Setup()
    local diedCon 
    diedCon = self.Humanoid.Died:Connect(function()
        diedCon:Disconnect()
        self.Running = false
        self.Actor = nil
        print("Ref Deleted!")
    end)

    self.Actor.PrimaryPart:SetNetworkOwner(nil)
end 

function BaseCreature:PlayAnimation(Name)
    EntityService:FireAnimation(self.EntityId, Name, nil)
end

function BaseCreature:Init()
    EntityService = BaseCreature.Services.EntityService
end


return BaseCreature