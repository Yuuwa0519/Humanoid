-- Dummy
-- Yuuwa0519
-- August 1, 2020

--Module
local BaseCreature

--Var 
local DummyBase = {
    Specie = "Dummy";

    ClothingId = "Dummy";
    ClothingCF = CFrame.new();
    
    AnimDictionary = {};


    HumanoidSettings = {
        WalkSpeed = 120;
        Drag = 20;
    };
}

local Rand = Random.new()

local Dummy = {}
Dummy.__index = Dummy

function Dummy.new()
    local newDino = setmetatable(BaseCreature.new(CreatureEntity, DummyBase), Dummy)

    return newDino
end

function Dummy:StartLogic()
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

function Dummy:EndLogic()
    self.Running = false
end 



function Dummy:Init()
    BaseCreature = self.Modules.Creature.BaseCreature
    setmetatable(Dummy, BaseCreature)
end

return Dummy