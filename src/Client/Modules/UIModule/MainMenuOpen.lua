-- Main Menu Open
-- Yuuwa0519
-- August 7, 2020

--Obj
local Button
local MainFrame

--Var
local isOpen = false

local MainMenuOpen = {}

function MainMenuOpen:ManipUI()
    isOpen = not isOpen 
    MainFrame.Visible = isOpen
end

function MainMenuOpen:Setup(UI, Main)
    Button = UI
    MainFrame = Main.MainMenu

    Button.MainToggle.MouseButton1Down:Connect(function()
        self:ManipUI()
    end)
end

return MainMenuOpen