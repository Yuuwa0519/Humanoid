-- Character Handle Server
-- Yuuwa0519
-- July 26, 2020

--Service
local ServerStorage = game:GetService("ServerStorage")

--Obj 
local CharacterObj = ServerStorage.Characters.PlayerChar

--Events 
local CEvents = {
    "Spawn";
    "StartCharControl";
    "Died";
}

--Var 
local DeployedChars = {}

local CharacterHandleServer = {Client = {}}

function CharacterHandleServer:SpawnPlr(plr)
    -- local newChar = CharacterObj:Clone() 
    -- local newHum = self.Shared.Humanoid.new(newChar)

    --Setup the Properties
    
end

function CharacterHandleServer:Start()
    self:ConnectClientEvent("Spawn", function(...)
        self:SpawnPlr(...)
    end)
end

function CharacterHandleServer:Init()
    for _, name in pairs(CEvents) do 
        self:RegisterClientEvent(name)
    end
end

return CharacterHandleServer