-- Entity Object
-- Yuuwa0519
-- July 28, 2020

--Service 
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Obj
local VisualCache = ReplicatedStorage.CacheVisual

--Var 
local Maid 

local EntityObject = {}
EntityObject.__index = EntityObject 

function EntityObject.new(Id, Obj, ClientObj, AnimArray)
    -- print("New Entity Creating")
    local newEntity = setmetatable({
        Id = Id; 
        ServerObj = Obj;
        ClientObj = ClientObj;
        AnimationArray = AnimArray;

        ServerRoot = nil;
        ClientRoot = nil;
        AnimationController = nil;

        Weld = nil;

        IsMounted = false;

        _Maid = Maid.new()
    }, EntityObject)

    return newEntity
end 

function EntityObject:Mount()
    -- print("Mount")
    if (self.IsMounted) then warn("Already mounted", self.Id) return end

    self.ServerRoot = self.ServerObj.PrimaryPart
    self.ClientRoot = self.ClientObj.PrimaryPart 

    --Set up Weld 
    self.Weld = self.ClientRoot:FindFirstChild("RootWeld")
    self.AnimationController = self.ClientObj:FindFirstChild("AnimationController")

    if (self.Weld and self.AnimationController) then
        --Set CF of Client Obj
        self.ClientRoot.Anchored = false
        self.ClientObj:SetPrimaryPartCFrame(self.ServerObj:GetPrimaryPartCFrame():ToWorldSpace(CFrame.new(0, 0, 0)))
        self.Weld.Part1 = self.ServerRoot
        self.ClientObj.Parent = self.ServerObj 

        self.IsMounted = true
    else
        warn("The EntityCreation Failed. No ")
        self:UnMount()
    end 
end 

function EntityObject:UnMount()
    -- print("UnMount")
    if (not self.IsMounted) then warn("Not Mounted", self.Id) return end 
    
    --Cache instead of Destroy
    self.Weld.Part1 = nil 

    self.ClientRoot.Anchored = true 
    self.ClientObj.Parent = VisualCache

    self.IsMounted = false
end 

function EntityObject:PlayAnimation(name)
    if (not self.LoadedAnims[name]) then
        self:LoadAnimation(name)
    end 

    self.LoadedAnim[name]:Play()
end 

function EntityObject:StopAnimation(name)
    if (self.LoadedAnim[name]) then
        self.LoadedAnim[name]:Stop()
    end 
end

function EntityObject:LoadAnimation(name)
    local animObj = Instance.new("Animation")
    animObj.AnimationId = self.AnimationArray[name] 

    if (animObj.AnimationId) then
        self.LoadedAnim[name] = self.AnimationController:LoadAnimation(animObj)
        animObj:Destroy()
    else
        warn("Untracked Animid", name)
        print(self.AnimationArray)
    end
end 

function EntityObject:GetPlayingTracks()
    return self.AnimationController:GetPlayingAnimationTracks()
end 

function EntityObject:Destroy()
    self.ClientObj:Destroy()
    self._Maid:Destroy()
end 

function EntityObject:Init()
    Maid = self.Shared.Maid 
end 

return EntityObject