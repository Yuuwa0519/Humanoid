-- RenderedNPC
-- Yuuwa0519
-- August 7, 2020

local Frame



local RenderedNPC = {}

function RenderedNPC:ShowStats()
    while (wait(1)) do 
        Frame.Text.Text = self.Controllers.EntityController:GetEntityStats()
    end
end 

function RenderedNPC:Setup(UI)
    Frame = UI
    self:ShowStats()
end 

return RenderedNPC