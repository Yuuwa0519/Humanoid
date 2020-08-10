-- Entity Service
-- Yuuwa0519
-- July 29, 2020

--Vars 
local EntityIds = -100000
local AllEntities = {}

local CEvents = {
    "PlayAnimation";
}

--Setting 
local EntityService = {Client = {}}

function EntityService:AddEntity(Actor, BaseArray)
    local Clothing = BaseArray.ClothingId
    local AnimDictionary = BaseArray.AnimDictionary
    local ClothingCF = BaseArray.ClothingCF
    local Id = EntityIds 
    EntityIds += 1 

    local AncestryCon

    local newEntity = {
        Id = Id;
        Actor = Actor;
        ClothingId = Clothing;
        ClothingCF = ClothingCF;
        AnimDict = AnimDictionary;
    }

    AllEntities[Id] = newEntity

    AncestryCon = Actor.AncestryChanged:Connect(function(_, new)
        print("Ancestry Changed on Entity", new)
        if (new == nil) then 
            AncestryCon:Disconnect()
            self:RemoveEntity(Id)
        end
    end)


    return Id
end 

function EntityService:RemoveEntity(Id)
    local EntityData = AllEntities[Id]
    if (EntityData) then
        --Memory Leakage may happen? idk :P 
        AllEntities[Id] = nil 
        print("Removed " .. Id)
    else 
        warn("Remove Entity ", Id, " Non Existance")
    end 
end 

function EntityService:GetEntity(Id)
    return AllEntities[Id]
end

function EntityService:GetEntities(Position, Radius)
    local returningEntities = {}

    for _, Entity in pairs(AllEntities) do 
        local Actor = Entity.Actor 
        
        if (Actor) then
            local PrimaryPart = Actor.PrimaryPart
            if (PrimaryPart) then
                if ((PrimaryPart.Position - Position).Magnitude < Radius) then 
                    table.insert(returningEntities, {Id = Entity.Id, Pos = PrimaryPart.Position})
                end
            else 
                warn("Lacks PrimaryPart, " .. Entity.Id)
                self:RemoveEntity(Entity.Id)
            end
        else 
            warn("Lacks Actor", Entity.Id)
            self:RemoveEntity(Entity.Id)
        end
    end

    return returningEntities   
end 

function EntityService:FireAnimation(EntityId, AnimName, PlrtoIgnore)
    if (PlrtoIgnore) then
        self:FireOtherClients("PlayAnimation", PlrtoIgnore, EntityId, AnimName)
    else
        self:FireAllClients("PlayAnimation", EntityId, AnimName) 
    end 
end 

function EntityService.Client:DownloadEntity(_, id)
    return self.Server:GetEntity(id)
end 

function EntityService.Client:GetEntities(_, ...)
    return self.Server:GetEntities(...)
end 

function EntityService:Init()
    for _, name in pairs(CEvents) do 
        self:RegisterClientEvent(name)
    end 
end 


return EntityService