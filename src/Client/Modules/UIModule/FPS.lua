-- FPS
-- Yuuwa0519
-- August 7, 2020

--Services
local RunService = game:GetService("RunService")

--Obj
local FPSShower

local FPS = {}

function FPS:CalcFPS()
    RunService.RenderStepped:Connect(function(delta)
        FPSShower.Text.Text = math.floor((1 / delta))
    end)
end

function FPS:Setup(UI)
    FPSShower = UI
    self:CalcFPS()
end

return FPS