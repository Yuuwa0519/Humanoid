-- Entity Object
-- Yuuwa0519
-- July 30, 2020

--Obj
local EntityFolder = workspace:WaitForChild("Entities")

--Module
local Maid
local CacheManager
local AssetManager

local EntityObject = {}
EntityObject.__index = EntityObject

function EntityObject.new(EntityData)
    local Id = EntityData.Id 
    local Actor = EntityData.Actor 
    local ClothingOrig = AssetManager:GetAsset(EntityData.ClothingId)
    local AnimDict = EntityData.AnimDict

    local ClothingCF = EntityData.ClothingCF

    if (Actor) then 
        if (ClothingOrig) then
            local Clothing = ClothingOrig:Clone()
            local AnimController = Instance.new("AnimationController")
            local Weld = Instance.new("WeldConstraint")

            Weld.Part0 = Clothing.PrimaryPart

            AnimController.Parent = Clothing
            Weld.Parent = Clothing.PrimaryPart 

            local self = setmetatable({
                Id = Id;
                AnimDict = AnimDict;
                ClothingCF = ClothingCF;
                LoadedAnimation = false;

                Actor = Actor;
                Clothing = Clothing;
                AnimationController = AnimController;
                Weld = Weld;

                Mounted = false;
                DoNotLoad = false;

                _Maid = Maid.new();
            }, EntityObject)

            self._Maid:GiveTask(self.Clothing)
            self._Maid:GiveTask(self.Weld)
            self._Maid.OnDestroy = Clothing.AncestryChanged:Connect(function(old, new)
                if (new == nil) then 
                    self:Destroy()
                end
            end)

            return self
        else 
            warn("Clothing Not Visible from Client!", Id)
        end
    else
        warn("Actor Not Visible from Client!", Id)
    end 
end

function EntityObject:WearCloth()
    if (self.Mounted) then return end 
    if (self.DoNotLoad) then 
        warn("Called Wear Cloth Even though Do Not Load!", self.Id)
        return
    end 

    --Set CFrame
    self.Clothing:SetPrimaryPartCFrame(self.Actor:GetPrimaryPartCFrame():ToWorldSpace(self.ClothingCF))
    self.Clothing.PrimaryPart.Anchored = false
    self.Weld.Part1 = self.Actor.PrimaryPart
    self.Actor.PrimaryPart.Transparency = 1
    self.Clothing.Parent = EntityFolder

    self.Mounted = true

    -- print("#EntityFolder", #EntityFolder:GetChildren())
end
 
function EntityObject:TakeoffCloth()
    if (not self.Mounted) then return end 

    if (self.Clothing) then
        if (self.Clothing.PrimaryPart) then
            self.Clothing.PrimaryPart.Anchored = true 
            CacheManager:CacheModel(self.Clothing)
            self.Mounted = false
        else 
            warn("Not Took Off Cause no Clothing Primarypart!")
        end
    else 
        warn("Not Took Off Cause no Clothing!")
    end
end

function EntityObject:LoadAnimation(name, animId)
    local animObj = Instance.new("Animation")
    animObj.AnimationId = animId

    self.LoadedAnimation[name] = self.AnimationController:LoadAnimation(animObj)
end

function EntityObject:PlayAnim(name)
    local corresAnim = self.LoadedAnimation[name]
    if (corresAnim) then
        corresAnim:Play()
    end
end

function EntityObject:CancenAnim(name)
    local corresAnim = self.LoadedAnimation[name]
    if (corresAnim) then
        corresAnim:Cancel()
    end
end

function EntityObject:StopAnim(name)
    local corresAnim = self.LoadedAnimation[name]
    if (corresAnim) then
        corresAnim:Stop()
    end
end

function EntityObject:Destroy()
    -- print("EntityObject:Destroy()", self.Id)
    self.DoNotLoad = true
    self._Maid:Destroy()
end

function EntityObject:Init()
    Maid = self.Shared.Maid

    CacheManager = self.Modules.Entity.CacheManager
    AssetManager = self.Modules.Entity.AssetManager
end 

return EntityObject