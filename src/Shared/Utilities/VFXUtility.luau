--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage.Packages
local Utilities = ReplicatedStorage.Utilities
local Configuration = ReplicatedStorage.Configuration

local Sounds = require(Configuration.SoundConfig)
local SoundUtility = require(Utilities.SoundUtility)
local Promise = require(Packages.Promise)

local Assets = ReplicatedStorage:FindFirstChild("assets") :: Folder
local BulletBeam = Assets:FindFirstChild("BulletBeam") :: Beam

local VFXUtility = {}

function VFXUtility.Gunshot(Character: Model, HitPosition: Vector3)
	VFXUtility.BulletBeam(Character, HitPosition)
	SoundUtility.PlaySoundOnInstance(Sounds.Gunshot, Character.PrimaryPart :: BasePart)
end

function VFXUtility.BulletBeam(Entity: Instance, HitPosition: Vector3): ()
	local rightHand = Entity:FindFirstChild("RightHand") :: BasePart
	if not rightHand then
		return
	end

	local beamClone = BulletBeam:Clone()

	assert(beamClone, "No beam found")

	local startPart = Instance.new("Part")
	local endPart = Instance.new("Part")

	local parts = { startPart, endPart }
	parts[1].CFrame = rightHand.CFrame
	parts[2].CFrame = CFrame.new(HitPosition)

	for _, part in parts do
		part.Size = Vector3.new(0.1, 0.1, 0.1)
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Transparency = 1
		part.Parent = workspace
	end

	local initialAttachment = Instance.new("Attachment")
	initialAttachment.Parent = parts[1]

	local endAttachment = Instance.new("Attachment")
	endAttachment.Parent = parts[2]

	beamClone.Parent = rightHand
	beamClone.Attachment0 = endAttachment
	beamClone.Attachment1 = initialAttachment

	local transparencyTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	VFXUtility.TweenTransparencySequence(beamClone, 0, 1, transparencyTweenInfo):andThen(function()
		for _, part in parts do
			part:Destroy()
		end
		beamClone:Destroy()
	end)
end

function VFXUtility.TweenTransparencySequence(object: Beam, fromValue: number, toValue: number, tweenInfo: TweenInfo)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = fromValue

	numberValue.Changed:Connect(function(value)
		object.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, value),
			NumberSequenceKeypoint.new(1, value),
		})
	end)

	local tween = TweenService:Create(numberValue, tweenInfo, { Value = toValue })
	tween.Completed:Once(function()
		numberValue:Destroy()
	end)

	tween:Play()

	return Promise.fromEvent(tween.Completed, function()
		return true
	end)
end

function VFXUtility.EmitParticles(Part: BasePart): ()
	for _, emitter in Part:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			print("Emitting particles")
			emitter:Emit(emitter:GetAttribute("EmitCount") :: number? or 1)
		end
	end
end

return VFXUtility
