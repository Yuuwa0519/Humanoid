-- Animal Service
-- Yuuwa0519
-- August 1, 2020

--Module 
local Creature

--Var
local totalNPCs = 0
local AnimalList = {}

local CEvents = {
    "SpawnNPC"
}

local Rand = Random.new()

local AnimalService = {Client = {}}

function AnimalService:SpawnNPC()
    local chosen = Rand:NextInteger(1, #AnimalList)

    local newNPC = AnimalList[chosen].new() 

    totalNPCs += 1
    newNPC:StartLogic()
end

function AnimalService.Client:GetTotalNPC()
    return totalNPCs
end

function AnimalService:Start()
    self:ConnectClientEvent("SpawnNPC", function(plr)
        self:SpawnNPC()
    end)
    self:SpawnNPC()
end

function AnimalService:Init()
    Creature = self.Modules.Creature
    AnimalList = {
        Creature.Dinosaur;
        Creature.Dummy;
        Creature.Yuuwa0519;
    }
    
    for _, v in pairs(CEvents) do
        self:RegisterClientEvent(v)
    end
end


return AnimalService