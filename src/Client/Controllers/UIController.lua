-- UI Controller
-- Yuuwa0519
-- July 11, 2020

--Services
local CollectionService = game:GetService("CollectionService")

--Vars
local PlayerGui
local MainUI


local UIController = {}

function UIController:Setup()
    local UICollection = CollectionService:GetTagged("UICollection")

    for _, UI in pairs(UICollection) do 
        self.Modules.UIModule[UI.Name]:Setup()
    end 
end

function UIController:Start()
    PlayerGui = self.Player:WaitForChild("PlayerGui")
    MainUI = PlayerGui:WaitForChild("Main")

    self:Setup()
end

function UIController:Init()
	
end


return UIController