-- Humanoid
-- Yuuwa0519
-- July 11, 2020

--Service
local RunService = game:GetService("RunService")

--Var
local Maid
local Event

local Debug = true

--Function
local function fSpawn(func, ...) --From Nevermore Engine by Quenty, Modified by Crazyman32
	local args = table.pack(...)
	local bindable = Instance.new("BindableEvent")
	bindable.Event:Connect(function() func(table.unpack(args, 1, args.n)) end)
	bindable:Fire()
	bindable:Destroy()
end

local Humanoid = {}
Humanoid.__index = Humanoid

function Humanoid.new(Character)
	--[[Components
		VectorForce;
		BodyGyro;
		AnimationController;
	]]

	local HumBase = Character:WaitForChild("HumanoidBase")
	-- local BaseAttach = HumBase:FindFirstChild("Base")
	-- local RptAttach = HumBase:FindFirstChild("Rot")

	local BaseAttach = Instance.new("Attachment")
	local RotAttach = Instance.new("Attachment")

	local VF = Instance.new("VectorForce")
	local JF = Instance.new("VectorForce")
	local AO = Instance.new("AlignOrientation")

	VF.Attachment0 = BaseAttach
	VF.ApplyAtCenterOfMass = true

	JF.Attachment0 = BaseAttach
	JF.ApplyAtCenterOfMass = true
	JF.Force = Vector3.new()

	AO.Attachment0 = BaseAttach
	AO.Attachment1 = RotAttach
	AO.MaxTorque = 20000


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
		DragForce = 30;
		WalkSpeed = 70;
		AutoRotate = true; 
		Mass = 0;

		--Humanoid Components
		Health = 100;

		--Event
		MoveToFinished = Event.new();

		--Other
		_Maid = Maid.new();

	}, Humanoid)

	return self
end

function Humanoid:Jump()
	local jumpPower = Vector3.new(0, self:GetMass(true) * 1.5, 0)

	self.JF.Force = jumpPower
	wait(.5)
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

	if (self.AutoRotate) then 
		newV3 = Vector3.new(0, 0, -1)
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

	self.GoalPos = TargetPos
	self:Move(direction)

	self._Maid.MoveToEvent = RunService.Heartbeat:Connect(function()
		local dist = (TargetPos - self.Base.Position).Magnitude
		local deltaTime = (time() - startTim)

		if (dist < 1 or deltaTime > timeOut) then
			self._Maid.MoveToEvent:Disconnect()
			self:Move(Vector3.new())
			self.MoveToFinished:Fire()
		end
	end)
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
		local right = look:Cross(Vector3.new(0,1,0))
		local up = right:Cross(look)

		self.RotAttach.WorldCFrame = CFrame.fromMatrix(look, right, up)
	end


	local Force = self.Mass * (self.Direction * self.WalkSpeed)
	local Drag = vel * self.DragForce
	local FinalForce = Force - Drag

	self.VF.Force = FinalForce
end

function Humanoid:GetMass(considerGravity)
	local mass = 0
	for _, obj in pairs(self.Char:GetDescendants()) do
		if (obj:IsA("BasePart")) then
			mass = mass + obj:GetMass()
		end
	end

	return considerGravity and mass * workspace.Gravity or mass
end

function Humanoid:Activate()
	if (self.AutoRotate) then
		self.VF.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	else
		self.VF.RelativeTo = Enum.ActuatorRelativeTo.World
	end

	self.Mass = self:GetMass()
	self.LastDelta  = 0

	self._Maid:GiveTask(RunService.Heartbeat:Connect(function()
		self:Calculate()
	end))
end

function Humanoid:Deactivate()
	self._Maid:Destroy()
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

	print("Referenced")
end


return Humanoid