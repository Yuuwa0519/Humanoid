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

function BaseCreature.new(Clothing, AnimDict, EntityOffset)
    local Actor = HumBase:Clone()
    
    local EntityId = EntityService:AddEntity(Actor, Clothing, AnimDict, EntityOffset)

    local self = setmetatable({
        EntityId = EntityId;
        Running = false;

        Humanoid = BaseCreature.Shared.Humanoid.new(Actor);
    }, BaseCreature)

    return self
end

function BaseCreature:PlayAnimation(Name)
    EntityService:FireAnimation(self.EntityId, Name, nil)
end

function BaseCreature:Init()
    EntityService = BaseCreature.Services.EntityService
end


return BaseCreature