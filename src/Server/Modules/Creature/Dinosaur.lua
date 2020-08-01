-- Dinosaur
-- Yuuwa0519
-- August 1, 2020

--Service 
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Module
local BaseCreature

--Obj
local CreatureEntities = ReplicatedStorage.EntityObjects
local CreatureEntity = CreatureEntities.Dinosaur

--Var 
local DinosaurAnimations = {}
local DinosaurEntityOffset = CFrame.new()

local Rand = Random.new()

local Dinosaur = {}
Dinosaur.__index = Dinosaur

function Dinosaur.new()
    local newDino = setmetatable(BaseCreature.new(CreatureEntity, DinosaurAnimations, DinosaurEntityOffset), Dinosaur)
    
    return newDino
end

function Dinosaur:StartLogic()
    self.Running = true
    self.Shared.Thread.SpawnNow(function()
        while (self.Running) do
            local X = Rand:NextInteger(-50, 50)
            local Z = Rand:NextInteger(-50, 50)

            local nextPos = self.PrimaryPart.Position + Vector3.new(X, 0, Z)
            self.Humanoid:MoveTo(nextPos, 8)
            self.Humanoid.MoveToFinished:Wait()
            wait(1)
        end
    end)
end

function Dinosaur:EndLogic()
    self.Running = false
end 



function Dinosaur:Init()
    BaseCreature = self.Modules.Creature.BaseCreature
    setmetatable(Dinosaur, BaseCreature)
end

return Dinosaur