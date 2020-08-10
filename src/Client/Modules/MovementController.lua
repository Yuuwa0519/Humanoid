-- Movement Controller
-- Yuuwa0519
-- August 9, 2020

--Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--Module
local RobloxianController

--Obj
local Camera = workspace.CurrentCamera

local CurrentHumanoid = nil

--Variable
local MovementMap = {
    [Enum.KeyCode.W] = Vector3.new(0, 0, -1);
    [Enum.KeyCode.A] = Vector3.new(-1, 0, 0);
    [Enum.KeyCode.S] = Vector3.new(0, 0, 1);
    [Enum.KeyCode.D] = Vector3.new(1, 0, 0)
}

local Maid

local MovementController = {}

function MovementController:GetInput()
    local totalVector = Vector3.new()
    local isJump 

    local allKeys = UserInputService:GetKeysPressed()

    for _, key in pairs(allKeys) do 
        if (MovementMap[key.KeyCode]) then 
            totalVector += MovementMap[key.KeyCode]
        elseif (key.KeyCode == Enum.KeyCode.Space) then 
            isJump = true
        end
    end

    local CameraCF = Camera.CFrame
    local X, Y, Z = CameraCF:ToOrientation()
    local newCF = CFrame.Angles(0, Y, Z)
    local FinalVector = newCF:VectorToWorldSpace(totalVector)

    RobloxianController:TellControl(FinalVector, isJump, newCF.LookVector)
end

function MovementController:Deactivate()
    Maid:Destroy()
end

function MovementController:Activate()
    Maid._InputCon = RunService.RenderStepped:Connect(function()
        self:GetInput()
    end)
end

function MovementController:Start()
    RobloxianController = self.Controllers.RobloxianController
    Maid = self.Shared.Maid.new()
end

function MovementController:Init()
	
end

return MovementController