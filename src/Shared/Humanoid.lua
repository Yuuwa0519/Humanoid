-- Humanoid
-- Yuuwa0519
-- July 11, 2020 (Updated on July 26th, 2020)

--[[
	Documentation
	
	Constructors:
		Humanoid.new(Rig)
			->Make Sure to Have All Parts Except for base Part to be Massless

    Methods:
		Humanoid:Activate()
			-> Starts Calculating the Force of Vector Force to move in consistent speed

		Humanoid:Deactivate()
			-> Stops the calculation + disconnect all events made in Humanoid:Activate() 
			-> Call this When You Don't need the intense calculation to be running (For Ex, if the Humanoid is Going to be Idle for Few moments)
		
		Humanoid:Move(Vector3(UnitVector))
			-> Same as Roblox Humanoid:Move()

			Ex: Humanoid:Move(Vector3.new(0, 0, -1))

		Humanoid:MoveTo(Vector3(Destination), number(TimeOut))
			-> Same as Roblox Humanoid:MoveTo()
			-> Second Parameter Defaults to 8 Seconds
			
			Ex: Humanoid:MoveTo(Vector3.new(100,0,100), 12)
			
		Humanoid:Face(Vector3(Unit Vector))
			-> Make the Humanoid Face In Direction of Unit Vector

			Ex: Humanoid:Face(Camera.CFrame.LookVector))

		Humanoid:FaceTo(Vector3(Point to Look At))
			-> Make the Humanoid Face Towards Something

			Ex: Humanoid:FaceTo(Vector3.new(0, 500, 700))

        Humanoid:Jump()
			-> Humanoid will Jump XD

	Events: 
		ScriptSignal: Humanoid.MoveToFinished()
			-> Event That Fires when MoveTo() is called, and is done moving
		
	State: 
		Boolean: Humanoid.ReachedTarget
			-> Will be True if Previous Humanoid:MoveTo() Was Successful
]]

--Service
local RunService = game:GetService("RunService")

--Var
local Maid
local Event

local Debug = false

--Function

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

function Humanoid.new(Character, RAttach, HumSettings)
	--[[Components
		VectorForce;
		(Not Used)BodyGyro; --Differed Due to Performance Problems
		AllignOrientation;
		AnimationController; --Differed Due to Switching to Entity Render System
	]]

	local HumBase = Character.PrimaryPart

	local BaseAttach = HumBase:FindFirstChild("BaseAttach") or Instance.new("Attachment")
	local RotAttach = RAttach or Instance.new("Attachment")

	local VF = HumBase:FindFirstChild("MoveVectorForce") or Instance.new("VectorForce")
	local JF = HumBase:FindFirstChild("JumpVectorForce") or Instance.new("VectorForce")
	local AO = HumBase:FindFirstChild("CharacterAlignOrientation") or Instance.new("AlignOrientation")

	BaseAttach.Name = "BaseAttach"
	RotAttach.Name = "RotAttach"

	VF.Attachment0 = BaseAttach
	VF.ApplyAtCenterOfMass = true
	VF.Force = Vector3.new()
	VF.Enabled = false
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
		DragForce = (HumSettings.Drag or 60);
		WalkSpeed = (HumSettings.WalkSpeed or 120);
		Mass = 0;

		AutoRotate = true; 
		TargetReachDist = 5;		

		--State 
		ReachedTarget = true;
		Locked = false;

		--Humanoid Components
		Health = 100;

		--Event
		MoveToFinished = Event.new();
		Died = Event.new();

		--Other
		_Maid = Maid.new();
		_ObjMaid = Maid.new()

	}, Humanoid)

	self._ObjMaid:GiveTask(self.MoveToFinished)
	self._ObjMaid:GiveTask(self.Died)
	self._ObjMaid:GiveTask(self.Char)
	self._ObjMaid:GiveTask(self.RotAttach)
	self._ObjMaid:GiveTask(self.Char.AncestryChanged:Connect(function(_, new)
		if (new == nil) then 
			self:DeadSequence()
		end
	end))

	return self
end

function Humanoid:CreateHumFromClient(me, Character, RotationAttach)
	if (RunService:IsServer()) then 
		debugPrint(true, "CreateHumFromClient() Needs to Be Called From Client!!")
		return 
	end

	--Confirm the Player has NetworkOwner
	local OwnsNetwork = false

	local _, e = pcall(function()
		OwnsNetwork = Character.PrimaryPart:GetNetworkOwner() == me 
	end) 

	if (OwnsNetwork) then
		--Get Components
		local HumBase = Character:WaitForChild("HumanoidBase", 8)

		if (HumBase) then
			return self.new(Character, RotationAttach)
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
	if (not self.isLocked) then 
		self.VF.Enabled = true
		if (self.AutoRotate) then
			self.VF.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
		else
			self.VF.RelativeTo = Enum.ActuatorRelativeTo.World
		end

		self._Maid:GiveTask(RunService.Heartbeat:Connect(function()
			self:Calculate()
		end))
		self.Base.BrickColor = BrickColor.Green()
	else 
		warn("Called Activate on Locked Humanoid!")
	end 
end

function Humanoid:Deactivate()
	self._Maid:Destroy()
	-- self.Base.BrickColor = BrickColor.Red()
	if (not self.Locked) then
		self.VF.Enabled = false
		self.Base.BrickColor = BrickColor.Red()
	end 
end

function Humanoid:DeadSequence()
	warn("Death Sequence")
	self.Locked = true
	self:Deactivate()
	self.MoveToFinished:Fire()
	self.Died:Fire()

	self._ObjMaid:Destroy()
	for index, value in pairs(self) do 
		value = nil
	end 
	
	warn("Humanoid Death!")
	self.Shared.TableUtil.Print(self, "Humanoid")
end

function Humanoid:Init() 
	Maid = self.Shared.Maid 
	Event = self.Shared.Event

	debugPrint(false, "Referenced")
end


return Humanoid