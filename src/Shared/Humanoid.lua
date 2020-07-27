-- Humanoid
-- Yuuwa0519
-- July 11, 2020 (Updated on July 26th, 2020)

--Service
local RunService = game:GetService("RunService")

--Var
local Maid
local Event

local Debug = false

--Function
local function fSpawn(func, ...) --From Nevermore Engine by Quenty, Modified by Crazyman32
	local args = table.pack(...)
	local bindable = Instance.new("BindableEvent")
	bindable.Event:Connect(function() func(table.unpack(args, 1, args.n)) end)
	bindable:Fire()
	bindable:Destroy()
end

local function debugPrint(isWarn, ...)
	if (not Debug) then return end 

	if (isWarn) then
		warn(...)
	else 
		print(...) 
	end
end

local Humanoid = {}
Humanoid.__index = Humanoid

function Humanoid.new(Character, BAttach, RAttach, VForce, JForce, AOrientation)
	--[[Components
		VectorForce;
		(Not Used)BodyGyro; --Differed Due to Performance Problems
		AllignOrientation;
		AnimationController; --Differed Due to Switching to Client-Based
	]]

	local HumBase = Character:WaitForChild("HumanoidBase")
	-- local BaseAttach = HumBase:FindFirstChild("Base")
	-- local RptAttach = HumBase:FindFirstChild("Rot")

	local BaseAttach = BAttach or Instance.new("Attachment")
	local RotAttach = RAttach or Instance.new("Attachment")

	local VF = VForce or Instance.new("VectorForce")
	local JF = JForce or Instance.new("VectorForce")
	local AO = AOrientation or Instance.new("AlignOrientation")

	BaseAttach.Name = "BaseAttach"
	RotAttach.Name = "RotAttach"

	VF.Attachment0 = BaseAttach
	VF.ApplyAtCenterOfMass = true
	VF.Name = "MoveVectorForce"

	JF.Attachment0 = BaseAttach
	JF.ApplyAtCenterOfMass = true
	JF.Force = Vector3.new()
	JF.Name = "JumpVectorForce"

	AO.Attachment0 = BaseAttach
	AO.Attachment1 = RotAttach
	AO.MaxTorque = 20000
	AO.Name = "CharacterAlignOrientation"

	BaseAttach.Parent = HumBase
	RotAttach.Parent = workspace.Terrain
	VF.Parent = HumBase
	JF.Parent = HumBase
	AO.Parent = HumBase
	-- BG.Parent = HumBase

	local self = setmetatable({	
		Char = Character;
		Base = HumBase;
		BaseAttach = BaseAttach;
		RotAttach = RotAttach;
		VF = VF;
		JF = JF;
		AO = AO;

		--Physic Component
		Direction = Vector3.new(); --Move Direction
		GoalPos = Vector3.new(); --where to look if AutoRotate
		DragForce = 20;
		WalkSpeed = 120;
		Mass = 0;

		AutoRotate = true; 
		TargetReachDist = 5;		

		--State 
		ReachedTarget = true;

		--Humanoid Components
		Health = 100;

		--Event
		MoveToFinished = Event.new();
		Died = Event.new();

		--Other
		_Maid = Maid.new();

	}, Humanoid)

	return self
end

function Humanoid:CreateHumFromClient(me, Character, RotationAttach)
	if (RunService:IsServer()) then 
		debugPrint(true, "CreateHumFromClient() Needs to Be Called From Client!!")
		return 
	end

	--Confirm the Player has NetworkOwner
	local OwnsNetwork = false

	_, e = pcall(function()
		OwnsNetwork = Character.PrimaryPart:GetNetworkOwner() == me 
	end) 

	if (OwnsNetwork) then
		--Get Components
		local HumBase = Character:WaitForChild("HumanoidBase", 8)

		if (HumBase) then
			local BaseAttach = HumBase:FindFirstChild("BaseAttach")
			local RotAttach = RotationAttach

			local VF = HumBase:FindFirstChild("MoveVectorForce")
			local JF = HumBase:FindFirstChild("JumpVectorForce")
			local AO = HumBase:WaitForChild("CharacterAlignOrientation")

			return self.new(Character, BaseAttach, RotAttach, VF, JF, AO)
		end
	else 
		debugPrint(true, "The Local Player Needs Network Owner to Handle Humanoid!")
		debugPrint(true, e)
	end
end

function Humanoid:Jump()
	local jumpPower = Vector3.new(0, self:GetMass() * 3000, 0)

	self.JF.Force = jumpPower
	RunService.Heartbeat:Wait()
	self.JF.Force = Vector3.new()
end

function Humanoid:Move(V3)
	--If not AutoRotate, Move Towards in World Position
	--Else Move to V3.new(0,0,-1), while rotating Char

	local normalized = V3.Unit
	local newV3
	
	local X, Y, Z = normalized.X, normalized.Y, normalized.Z

	X = X == X and X or 0
	Y = Y == Y and Y or 0
	Z = Z == Z and Z or 0

	normalized = Vector3.new(X, Y, Z)

	--When Autorotate is Enabled, Move Vector Becomes Lookvector (Moves Forward)
	if (self.AutoRotate) then 
		if (normalized.Magnitude > 0) then
			newV3 = Vector3.new(0, 0, -1)
		else 
			newV3 = normalized
		end
	else
		newV3 = normalized
	end

	self.Direction = newV3
end

function Humanoid:MoveTo(TargetPos, timeOut)
	local nonHeightTarg = Vector3.new(TargetPos.X, self.Base.Position.Y, TargetPos.Z)
	local direction = (nonHeightTarg - self.Base.Position)

	local startTim = time()
	if (not timeOut) then
		timeOut = 8
	end

	self.ReachedTarget = false
	self.GoalPos = TargetPos
	self:Move(direction)

	self._Maid.MoveToEvent = RunService.Heartbeat:Connect(function()
		local dist = (TargetPos - self.Base.Position).Magnitude
		local deltaTime = (time() - startTim)

		if (dist < self.TargetReachDist or deltaTime > timeOut) then
			self._Maid.MoveToEvent:Disconnect()
			self:Move(Vector3.new())
			self.ReachedTarget = true
			self.MoveToFinished:Fire()
			
			debugPrint(false, "Reached, TimeOut: ", dist < self.TargetReachDist, deltaTime > timeOut)
		end
	end)
end

function Humanoid:Face(UnitVec) 
	--Manually Face Obj 
	--It will be Immideately Overwritten by Humanoid:Calculate() if Humanoid.Autorotate is True while Moving

	if (typeof(UnitVec) == "Vector3") then 
		local right = UnitVec:Cross(Vector3.new(0,1,0))
		local up = right:Cross(UnitVec)

		self.RotAttach.WorldCFrame = CFrame.fromMatrix(Vector3.new(), right, up)
	else 
		debugPrint(true, "Humanoid:Face() Requires Unit Vector")
	end
end

function Humanoid:FaceTo(TargCF)
	if (self.AutoRotate) then 
		debugPrint(true, "Humanoid:FaceTo() Cannot be Used while Humanoid.Autorotate is True")
		return 
	end

	if (typeof(TargCF) == "CFrame") then 
		local unitVec = (TargCF.Position - self.BaseAttach.WorldCFrame.Position).Magnitude 
		self:Face(unitVec)
	else
		debugPrint(true, "Humanoid:FaceTo() Requires Target CFrame")
	end
end

function Humanoid:Calculate()
	--F = MA
	--Drag = VC

	--If Autorotate, change vectorforce to attach0
	--Else change to world relative

	local vel = self.Base.Velocity 

	if (self.AutoRotate) then
		vel = self.BaseAttach.WorldCFrame:VectorToObjectSpace(vel)

		--Rotate towards Goal
		local nonHeightTarg = Vector3.new(self.GoalPos.X, self.Base.Position.Y, self.GoalPos.Z)
		local look = (nonHeightTarg - self.Base.Position).Unit
		self:Face(look)
	end


	local Force = self:GetMass() * (self.Direction * self.WalkSpeed)
	local Drag = vel * self.DragForce
	local FinalForce = Force - Drag

	self.VF.Force = FinalForce
end

function Humanoid:GetMass(considerGravity)
	return considerGravity and self.Base:GetMass() * workspace.Gravity or self.Base:GetMass()
end

function Humanoid:Activate()
	-- self.Base.BrickColor = BrickColor.White()
	self.VF.Enabled = true
	if (self.AutoRotate) then
		self.VF.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	else
		self.VF.RelativeTo = Enum.ActuatorRelativeTo.World
	end

	self._Maid:GiveTask(RunService.Heartbeat:Connect(function()
		self:Calculate()
	end))
end

function Humanoid:Deactivate()
	self._Maid:Destroy()
	-- self.Base.BrickColor = BrickColor.Red()
	self.VF.Enabled = false 
end

function Humanoid:Init() 
	--Call This right after require()ing this module
	--[[
		Maid = require(script.Maid)
		Event = require(script.Event)
		
		Uncomment This when Using without AeroGameFrameWork, and Comment out the one below this
		Maid From NevermoreEngine by Quenty
		Event by Crazyman32 in AGF
	]]
	Maid = self.Shared.Maid 
	Event = self.Shared.Event

	debugPrint(false, "Referenced")
end


return Humanoid