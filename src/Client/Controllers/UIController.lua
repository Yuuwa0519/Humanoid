-- UI Controller
-- Yuuwa0519
-- July 11, 2020

--Services
local RunService = game:GetService("RunService")

--Vars
local PlayerGui
local MainUI
local FPS
local Count
local Spawn


local UIController = {}

function UIController:FPSCheck()
    RunService.RenderStepped:Connect(function(delta)
        FPS.Text.Text = "FPS: " .. tostring(math.floor(1 / delta))
    end)
end

function UIController:CountCheck()
    self.Services.HumService.Spawned:Connect(function(num)
        Count.Text.Text = "#NPC: " .. num
    end)
end

function UIController:SpawnButton()
    Spawn.Text.MouseButton1Down:Connect(function()
        self.Services.HumService.Spawn:Fire()
    end)
    self.Services.HumService.Spawn:Fire()
end


function UIController:Start()
    PlayerGui = self.Player:WaitForChild("PlayerGui")

    MainUI = PlayerGui:WaitForChild("Main")

    FPS = MainUI:WaitForChild("FPS")
    Count = MainUI:WaitForChild("Count")
    Spawn = MainUI:WaitForChild("Spawn")

    self:FPSCheck()
    self:CountCheck()
    self:SpawnButton()
end

function UIController:Init()
	
end


return UIController