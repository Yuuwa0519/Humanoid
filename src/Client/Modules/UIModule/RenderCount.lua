-- Render Count
-- Yuuwa0519
-- August 7, 2020

--Obj
local Frame

local RenderCount = {}

function RenderCount:Setup(UI)
    Frame = UI
    
    Frame.Text.FocusLost:Connect(function()
        local text = tonumber(Frame.Text.Text)
        if (text) then
            Frame.Text.Text = text
            self.Modules.Entity.EntitySettings.MaxRenderCount = text
        else 
            Frame.Text.Text = self.Modules.Entity.EntitySettings.MaxRenderCount
        end
    end)
end 

return RenderCount