-- Asset Service
-- Yuuwa0519
-- August 8, 2020

--Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

--Obj
local AssetsFolder = ServerStorage.EntityObjects.ClientEntities

local AssetService = {Client = {}}

function AssetService:DownloadAsset(plr, Id)
    local isExist = AssetsFolder:FindFirstChild(Id)

    if (isExist) then 
        if (plr) then
            local ClientAssetDestination = plr:FindFirstChild("AssetDestination")

            if (ClientAssetDestination) then 
                local clone = isExist:Clone()
                clone.Parent = ClientAssetDestination
            end
        end
    end
end 

function AssetService.Client:DownloadAsset(...)
    self.Server:DownloadAsset(...)
end 

function AssetService:Start()
    Players.PlayerAdded:Connect(function(plr)
        local Folder = Instance.new("Folder")
        Folder.Name = "AssetDestination"
        Folder.Parent = plr
    end)	
end

return AssetService