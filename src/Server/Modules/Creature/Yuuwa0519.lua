-- Yuuwa
-- Yuuwa0519
-- August 1, 2020

--Module
local BaseCreature

--Var 
local YuuwaAnimations = {}
local YuuwaEntityOffset = CFrame.new()
local YuuwaBase = {
    Specie = "Yuuwa";

    ClothingId = "Yuuwa0519";
    ClothingCF = CFrame.new();
    
    AnimDictionary = {};


    HumanoidSettings = {
        WalkSpeed = 120;
        Drag = 20;
    };
}

local Rand = Random.new()

local Yuuwa = {}
Yuuwa.__index = Yuuwa

function Yuuwa.new()
    local newDino = setmetatable(BaseCreature.new(CreatureEntity, YuuwaBase), Yuuwa)

    return newDino
end

function Yuuwa:StartLogic()
    self.Actor.Parent = workspace.Characters
    self.Running = true

    self:Setup()
    
    self.Shared.Thread.SpawnNow(function()
        while (self.Running) do
            local X = Rand:NextInteger(-50, 50)
            local Z = Rand:NextInteger(-50, 50)

            local nextPos = self.Actor.PrimaryPart.Position + Vector3.new(X, 0, Z)

            self.Humanoid:Activate()
            self.Humanoid:MoveTo(nextPos, 8)
            self.Humanoid.MoveToFinished:Wait()
            self.Humanoid:Deactivate()
            wait(1)
        end
    end)
end

function Yuuwa:EndLogic()
    self.Running = false
end 

function Yuuwa:Init()
    BaseCreature = self.Modules.Creature.BaseCreature
    setmetatable(Yuuwa, BaseCreature)
end

return Yuuwa