-- SpawnNPC
-- Yuuwa0519
-- August 7, 2020

--Obj
local Frame

local SpawnNPC = {}

function SpawnNPC:Setup(UI)
    Frame = UI

    Frame.Button.MouseButton1Down:Connect(function()
        self.Services.AnimalService.SpawnNPC:Fire()
    end)
end 

return SpawnNPC