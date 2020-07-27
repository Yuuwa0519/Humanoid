-- Entity Manager
-- Yuuwa0519
-- July 26, 2020

--Service
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Var 
local ManagedEntity = {}

local CEvents = {

}

local EntityManager = {Client = {}}

function EntityManager:AddEntity(ServerObj, ClientObj, C0, AnimArray)
    local newEntity = {
        ClientObj = ClientObj;
        C0 = C0;
        Anims = AnimArray;
    };

    ManagedEntity[ServerObj] = newEntity
end

function EntityManager:RemoveEntity(Obj)
    ManagedEntity[Obj] = nil
end

function EntityManager:GetEntityData(plr, Obj)
    return ManagedEntity[Obj]
end 

function EntityManager.Client:GetEntityData(...)
    return self.Server:GetEntityData(...)
end

function EntityManager:Init()
    for _, name in pairs(CEvents) do
        self:RegisterClientEvent(name)
    end	
end

return EntityManager