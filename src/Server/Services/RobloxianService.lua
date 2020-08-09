-- Robloxian Service
-- Yuuwa0519
-- August 9, 2020

--Service
local Players = game:GetService("Players")

--Obj
local Spawn = workspace.PlayerSpawn

--Var
local CEvents = {
    "PlayAnimation";
    "RobloxianDead";
}

local Characters = {}


local RobloxianService = {Client = {}}

function RobloxianService:PlayAnimation(plr, animName)
    local character = Characters[plr]

    if (character) then 
        self.Serices.EntityService:FireAnimation(character.EntityId, animName, plr)
    else 
        warn("Recieved Anim Request Although har Not Exist!!")
    end
end

function RobloxianService:SpawnPlr(plr)
    if (Characters[plr]) then 
        Characters[plr]:Destroy()
    end

    local newCharacter = self.Modules.Creature.Robloxian.new()
    newCharacter.Actor.Parent = workspace.Characters
    newCharacter.Actor:SetPrimaryPartCFrame(Spawn.CFrame)
    newCharacter:Setup(plr)

    Characters[plr] = newCharacter

    return Characters[plr].EntityId
end

function RobloxianService.Client:SpawnMe(...)
    return self.Server:SpawnPlr(...)
end

function RobloxianService:Start()
    -- self:ConnectClientEvent("PlayAnimation", function(...)
    --     self:PlayAnimation(...)
    -- end)
end

function RobloxianService:Init()
	Players.CharacterAutoLoads = false
end


return RobloxianService