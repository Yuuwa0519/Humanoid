-- UI Controller
-- Yuuwa0519
-- July 11, 2020

--Services
local CollectionService = game:GetService("CollectionService")

--Var
local PlayerGui
local Main

local UIController = {}

function UIController:Setup()
    local UICollection = CollectionService:GetTagged("UICollection")

    for _, UI in pairs(UICollection) do 
        self.Modules.UIModule[UI.Name]:Setup(UI, Main)
    end 
end

function UIController:Start()
    repeat 
        wait()
    until _G.GuiLoaded == true 

    PlayerGui = self.Player:WaitForChild("PlayerGui")
    Main = PlayerGui.Main
    
    self:Setup()
end

return UIController