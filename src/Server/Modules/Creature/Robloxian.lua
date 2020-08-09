-- Robloxian
-- Yuuwa0519
-- August 8, 2020

--Module
local BaseCreature

--Var 
local RobloxianAnimations = {}

local RobloxianBase = {
    Specie = "Robloxian";

    ClothingId = "Robloxian";
    ClothingCF = CFrame.new();
    
    AnimDictionary = {};

    HumanoidSettings = {
        WalkSpeed = 120;
        Drag = 20;
    };
}

local Rand = Random.new()

local Robloxian = {}
Robloxian.__index = Robloxian

function Robloxian.new()
    local newRobloxian = setmetatable(BaseCreature.new(CreatureEntity, RobloxianBase), Robloxian)

    return newRobloxian
end

function Robloxian:Init()
    BaseCreature = self.Modules.Creature.BaseCreature
    setmetatable(Robloxian, BaseCreature)
end

return Robloxian