-- Render Dist
-- Yuuwa0519
-- August 8, 2020

--Obj
local Frame

local RenderDist = {}

function RenderDist:Setup(UI)
    Frame = UI
    
    Frame.Text.FocusLost:Connect(function()
        local text = math.clamp(tonumber(Frame.Text.Text), 20, self.Modules.Entity.EntitySettings.CacheRemoveDist - 1)
        if (text) then
            Frame.Text.Text = text
            self.Modules.Entity.EntitySettings.MaxRenderDist = text
        else 
            Frame.Text.Text = self.Modules.Entity.EntitySettings.MaxRenderDist
        end
    end)
end 

return RenderDist