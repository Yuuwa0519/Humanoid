-- Robloxian Controller
-- Yuuwa0519
-- August 9, 2020

--Modules
local RobloxianService
local EntityService
local EntityController

local Humanoid

--Obj
local MyActor = nil
local MyHumanoid = nil

local EntityFolder

local Camera = workspace.CurrentCamera

--Var
local HumDiedCon

local RobloxianController = {}

function RobloxianController:GetHumanoid()
    return MyHumanoid
end

function RobloxianController:Die()
    if (MyHumanoid) then 
        MyHumanoid.Char:Destroy()
    end
end

function RobloxianController:TellControl(moveVec, jump, camLook)
    if (MyHumanoid) then 
        MyHumanoid:Move(moveVec)

        if (camLook) then 
            if (not MyHumanoid.AutoRotate) then
                MyHumanoid:Face(camLook)
            end
        end
        if (jump) then 
            MyHumanoid:Jump()
        end
    end
end

function RobloxianController:ConnectToChar()
    if (HumDiedCon) then 
        HumDiedCon:Disconnect()
    end

    if (MyHumanoid) then 
        print("For Some Reason Previous Humanoid is Still Present...")
        MyHumanoid:DeadSequence()
    end

    local MyEntityId = RobloxianService:SpawnMe()

    if (MyEntityId) then 
        print("My Character EntityId: ", MyEntityId)
        local Entity = EntityService:DownloadEntity(MyEntityId)

        if (Entity) then
            local Actor = Entity.Actor
            
            if (Actor) then
                EntityController:AddForceRender(MyEntityId)

                MyHumanoid = Humanoid.new(Actor, nil, {WalkSpeed = 120, Drag = 30})

                HumDiedCon = MyHumanoid.Died:Connect(function()
                    HumDiedCon:Disconnect()
                    self:ConnectToChar()
                end)
                MyHumanoid:SwitchRotateMode(true)
                MyHumanoid:AddRayIgnore({EntityFolder})
                -- MyHumanoid.AO.RigidityEnabled = true
                MyHumanoid:Activate()

                Camera.CameraSubject = Actor.PrimaryPart
                Camera.CameraType = Enum.CameraType.Custom

                self.Modules.MovementController:Activate()
            else 
                warn("Actor is Invalid. Respawning!")
                self:ConnectToChar()
            end
        else 
            warn("Didn't Recieve Entity!")
        end
    else 
        warn("Didn't Recieve Entity Id")
    end
end

function RobloxianController:Start()
    RobloxianService = self.Services.RobloxianService
    EntityService = self.Services.EntityService
    EntityController = self.Controllers.EntityController
    Humanoid = self.Shared.Humanoid

    EntityFolder = workspace:WaitForChild("Entities")

    --Wait For Entity Controller to be Ready
    self:ConnectToChar()
end


function RobloxianController:Init()
	
end


return RobloxianController