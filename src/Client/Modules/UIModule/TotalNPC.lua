-- TotalNPC
-- Yuuwa0519
-- August 7, 2020

--Obj
local Frame

local TotalNPC = {} 

function TotalNPC:ShowStats()
    workspace:WaitForChild("Characters")
    while (wait(1)) do
        Frame.Text.Text = #workspace.Characters:GetChildren()
    end
end

function TotalNPC:Setup(UI)
    Frame = UI
    self:ShowStats()
end 

return TotalNPC