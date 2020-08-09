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

function BaseCreature.new(Clothing, BaseArray)
    local Actor = HumBase:Clone()
    local EntityId = EntityService:AddEntity(Actor, BaseArray)

    local creatureArray = {
        EntityId = EntityId;
        Running = false;
        Actor = Actor;

        Humanoid = BaseCreature.Shared.Humanoid.new(Actor, nil, BaseArray.HumanoidSettings);
        _Maid = Maid.new();
    }
    local merged = mergeTable(creatureArray, (baseArray or {}))

    local self = setmetatable(merged, BaseCreature)

    self._Maid.diedCon = self.Humanoid.Died:Connect(function()
        self._Maid.diedCon:Disconnect()
        self.Running = false
        self.Actor = nil
        print("Ref Deleted!")
    end)
    self._Maid:GiveTask(self.Actor)

    return self
end

function BaseCreature:Setup(owner)
    self.Actor.PrimaryPart:SetNetworkOwner(owner or nil)
end 

function BaseCreature:Destroy()
    EntityService:RemoveEntity(self.EntityId)
    self._Maid:Destroy()
end

function BaseCreature:PlayAnimation(Name)
    EntityService:FireAnimation(self.EntityId, Name, nil)
end

function BaseCreature:Init()
    EntityService = BaseCreature.Services.EntityService
    Maid = self.Shared.Maid
end


return BaseCreature