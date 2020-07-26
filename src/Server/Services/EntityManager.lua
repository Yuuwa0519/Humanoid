-- Entity Manager
-- Yuuwa0519
-- July 26, 2020

--Service
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Var 
local ManagedEntity = {}
local EntityIds

local CEvents = {

}

local EntityManager = {Client = {}}

function EntityManager:AddEntity(serverObj, clientObj, animArray)
    local Id = EntityIds
    EntityIds += 1

    local newEntity = {
        ServerObj = ServerObj;
        ClientObj = ClientObj;
        Anims = animArray;
    };

    ManagedEntity[Id] = newEntity
    return Id
end

function EntityManager:RemoveEntity(Id)
    ManagedEntity[Id] = nil
end

function EntityManager:GetEntity(Id)
    return ManagedEntity[Id]
end 

function EntityManager.Client:GetEntity(Id)
    return self.Server:GetEntity(Id)
end

function EntityManager:Init()
    for _, name in pairs(CEvents) do
        self:RegisterClientEvent(name)
    end	
end

return EntityManager