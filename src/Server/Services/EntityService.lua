-- Entity Service
-- Yuuwa0519
-- July 29, 2020

--Services 
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Vars 
local EntityIds = -100000
local AllEntities = {}

local CEvents = {
    "PlayAnimation";
}

--Setting 
local EntityCollectionTag = "_Entity"

local EntityService = {Client = {}}

function EntityService:AddEntity(Actor, Clothing, AnimDictionary, ClothingCF)
    local Id = EntityIds 
    EntityIds += 1 

    local newEntity = {
        Id = Id;
        Actor = Actor;
        Clothing = Clothing;
        AnimDict = AnimDictionary;

        ClothingCF = ClothingCF
    }

    AllEntities[Id] = newEntity
    CollectionService:AddTag(Actor, EntityCollectionTag) 
end 

function EntityService:RemoveEntity(Id)
    local EntityData = AllEntities[Id]
    if (EntityData) then
        if (EntityData.Actor) then 
            CollectionService:RemoveTag(EntityData.Actor, EntityCollectionTag)
        end

        --Memory Leakage may happen? idk :P 
        AllEntities[Id] = nil 
    end 
end 

function EntityService:GetEntity(identifier)
    if (type(identifier) == "userdata") then 
        --Assume that identifier is Server Actor 
        local Entity 

        for _, candidate in pairs(AllEntities) do 
            if (candidate.Actor == identifier) then
                Entity = candidate
                break 
            end 
        end 

        return Entity    
    else 
        --Assume that Identifier is Entity Id
        return AllEntities[identifier] 
    end 
end

function EntityService:FireAnimation(EntityId, AnimName, PlrtoIgnore)
    if (PlrtoIgnore) then
        self:FireOtherClients("PlayAnimation", PlrtoIgnore, EntityId, AnimName)
    else
        self:FireAllClients("PlayAnimation", EntityId, AnimName) 
    end 
end 

function EntityService.Client:DownloadEntity(plr, identifier)
    return self.Server:GetEntity(identifier)
end 

function EntityService:Init()
    for _, name in pairs(CEvents) do 
        self:RegisterClientEvent(name)
    end 
end 


return EntityService