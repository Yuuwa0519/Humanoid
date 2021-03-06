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
local Debris = game:GetService("Debris")

--Module
local Maid
local Event

--Setting
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

	local WalkSpeed = HumSettings and HumSettings.WalkSpeed or 120
	local Drag = HumSettings and HumSettings.Drag or 60

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
		OrigDirection = Vector3.new(); --Original Move Direction, When Autorotate is True
		GoalPos = Vector3.new(); --where to look if AutoRotate

		GroundNormal = Vector3.new(0, 1, 0);
		GroundFriction = 0;
		GroundFrictionWeight = 0;
		MyFriction = 0;
		MyFrictionWeight = 0;

		
		DragForce = Drag;
		WalkSpeed = WalkSpeed;
		Mass = 0;

		AutoRotate = true; 
		TargetReachDist = 5;	
		
		RayIgnoreList = {HumBase};
		RayParam = RaycastParams.new();
		--State 
		ReachedTarget = true;
		Locked = false;
		IsGrounded = true;

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
		print("Changed Ancestry", new)
		if (new == nil) then 
			self:DeadSequence()
		end
	end))

	return self
end

function Humanoid:AddRayIgnore(array)
	for _, obj in pairs(array) do 
		table.insert(self.RayIgnoreList, obj)
	end
	self.RayParam.FilterDescendantsInstances = self.RayIgnoreList
end

function Humanoid:SetRayIgnoreCollision(name)
	self.RayParam.CollisionGroup = name
end

function Humanoid:GetMass(considerGravity)
	return considerGravity and self.Base:GetMass() * workspace.Gravity or self.Base:GetMass()
end

function Humanoid:SwitchRotateMode(autoRotate)
	self.AutoRotate = not not autoRotate

	if (self.AutoRotate) then
		self.VF.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	else
		self.VF.RelativeTo = Enum.ActuatorRelativeTo.World
	end	
end

function Humanoid:Jump()
	if (self.IsGrounded) then
		local jumpPower = Vector3.new(0, self:GetMass() * 3000, 0)

		self.JF.Force = jumpPower
		RunService.Heartbeat:Wait()
		self.JF.Force = Vector3.new()
	end
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
			self.OrigDirection = normalized
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
	--Check Grounded
	do 
		local origin = self.BaseAttach.WorldCFrame:PointToWorldSpace(Vector3.new(0, -(self.Base.Size.Y / 2) + 0.1, 0))
		local direction = Vector3.new(0, -10, 0)
		local rayResult = workspace:Raycast(origin, direction, self.RayParam)

		if (rayResult) then 
			if ((origin - rayResult.Position).Magnitude < 1) then
				self.IsGrounded = true
			else 
				self.IsGrounded = false
			end

			self.GroundNormal = rayResult.Normal
			
			local groundObj = rayResult.Instance 

			if (groundObj.CustomPhysicalProperties) then 
				self.GroundFriction = groundObj.CustomPhysicalProperties.Friction
				self.GroundFrictionWeight = groundObj.CustomPhysicalProperties.FrictionWeight
			else 
				local material = rayResult.Material 

				--Define Friction from object material
				local PhysicsProperty = PhysicalProperties.new(material)

				if (PhysicsProperty) then 
					self.GroundFriction = PhysicsProperty.Friction
					self.GroundFrictionWeight = PhysicsProperty.FrictionWeight
				else 
					warn("No Physics Property")
				end
			end
		else 
			self.IsGrounded = false
			self.GroundNormal = Vector3.new(0, 1, 0)
		end
	end

	--Get Counter Force to Ground
	local gravity = self:GetMass() * workspace.Gravity
	local theta = Vector3.new(0, 1, 0):Dot(self.GroundNormal)

	local right = Vector3.new(0, 1, 0):Cross(self.GroundNormal)
	local planeCFrame = CFrame.fromMatrix(Vector3.new(), right, self.GroundNormal)
	local planeDirection = planeCFrame.LookVector

	--Test
	-- do
	-- 	local p = Instance.new("Part")
	-- 	p.CFrame = planeCFrame
	-- 	p.Position = workspace.PlayerSpawn.Position
	-- 	p.FrontSurface = Enum.SurfaceType.Hinge
	-- 	p.Size = Vector3.new(1, 1, 5)
	-- 	p.Anchored = true
	-- 	p.Parent = workspace.Entities
	-- 	Debris:AddItem(p, 1)
	-- end

	--[[
		Trig XD
		(Gravitatioal Pull Perpendicular to Plane)
		cos(angle) = perpendicularForce / Gravity
		 perpendicularForce = cos(angle) * Gravity

		(GravitationalPull Parallel to Plane)
		sin(angle) = parallelForce / Gravity
		parallelForce = sin(angle) * Gravity
	]]
	local forceParallel = math.sin(theta) * gravity

	--Get Friction Between Surface and HumBase
	--[[
		FrictionFormlula

		Fric AB = Fric A * FricWeightA + Fric B * FricWeightB 
					---------------------------------------------
							FricWeightA + FricWeightB
	]]
	local FrictionNumerator = self.MyFriction * self.MyFrictionWeight + self.GroundFriction * self.GroundFrictionWeight
	local FrictionDenominator = self.MyFrictionWeight + self.GroundFrictionWeight

	local Friction = FrictionNumerator / FrictionDenominator

	--F = MA
	--Drag = VC

	--If Autorotate, change vectorforce to attach0
	--Else change to world relative

	local vel = self.Base.Velocity 

	if (self.AutoRotate) then
		vel = self.BaseAttach.WorldCFrame:VectorToObjectSpace(vel)
		planeDirection = self.BaseAttach.WorldCFrame:VectorToObjectSpace(planeDirection)
		--Rotate towards Goal
		self:Face(self.OrigDirection)
	end


	local Force = self:GetMass() * (self.Direction * self.WalkSpeed)
	local Drag = vel * self.DragForce

	local FinalForce = (Force - Drag) 
	local FinalCounterForce = planeDirection * (forceParallel)

	self.VF.Force = FinalForce + FinalCounterForce
	-- print(FinalCounterForce)
end

function Humanoid:Activate()
	if (not self.isLocked) then 
		local PhysicsProperty = PhysicalProperties.new(self.Base.Material)

		if (PhysicsProperty) then 
			self.MyFriction = PhysicsProperty.Friction
			self.MyFrictionWeight = PhysicsProperty.FrictionWeight
		else 
			warn("No My Physical Property")
		end

		self.VF.Enabled = true

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
	-- self.Shared.TableUtil.Print(self, "Humanoid")
end

function Humanoid:Init() 
	Maid = self.Shared.Maid 
	Event = self.Shared.Event

	debugPrint(false, "Referenced")
end


return Humanoid