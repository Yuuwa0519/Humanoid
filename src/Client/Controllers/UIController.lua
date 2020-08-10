-- UI Controller
-- Yuuwa0519
-- July 11, 2020

--Services
local CollectionService = game:GetService("CollectionService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

--Obj
local ResetBind = Instance.new("BindableEvent")

--Var
local PlayerGui
local Main

local UIController = {}

function UIController:GetMainUI()
    return Main
end 

function UIController:ResetCallback()
    self.Controllers.RobloxianController:Die()
end

function UIController:Setup()
    local UICollection = CollectionService:GetTagged("UICollection")

    for _, UI in pairs(UICollection) do
        self.Shared.Thread.Spawn(function() 
            self.Modules.UIModule[UI.Name]:Setup(UI, Main)
        end)
    end 
end

function UIController:Start()
    ResetBind.Event:Connect(function()
        self:ResetCallback()
    end)
    while (true) do 
        local s, e = pcall(function()
            StarterGui:SetCore("ResetButtonCallback", ResetBind)
        end)

        if (s) then
            break
        end
        RunService.Heartbeat:Wait()
    end
    
    repeat 
        wait()
    until _G.GuiLoaded == true 

    PlayerGui = self.Player:WaitForChild("PlayerGui")
    Main = PlayerGui.Main
    
    self:Setup()
end

return UIController