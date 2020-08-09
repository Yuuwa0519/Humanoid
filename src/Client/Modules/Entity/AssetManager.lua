-- Asset Manager
-- Yuuwa0519
-- August 8, 2020

--Services
local Players = game:GetService("Players")

--Obj
local AssetsFolder

local NextDownload 
local DownloadAllowed = true

--Var
local DownloadedAssets = {}

local AssetManager = {}

function AssetManager:GetAsset(AssetId)
    if (not DownloadAllowed) then 
        NextDownload:Wait()
    end

    local isExist = DownloadedAssets[AssetId] 

    if (isExist) then 
        return isExist
    else 
        self:DownloadAsset(AssetId)

        return DownloadedAssets[AssetId]
    end
end 

function AssetManager:DownloadAsset(AssetId)
    DownloadAllowed = false

    if (not AssetsFolder) then 
        AssetsFolder = self.Player:WaitForChild("AssetDestination")
    end

    self.Services.AssetService:DownloadAsset(AssetId)
    local DownloadedAsset = AssetsFolder:WaitForChild(AssetId)

    DownloadedAssets[AssetId] = DownloadedAsset 
    DownloadAllowed = true
    NextDownload:Fire()
end 

function AssetManager:Init()
    NextDownload = self.Shared.Event.new()
end

return AssetManager