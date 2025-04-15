--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Assets = ServerStorage:FindFirstChild("assets") :: Folder
local Packages = ReplicatedStorage.Packages

local Targets = Assets:FindFirstChild("targets") :: Folder

local Components = require(ReplicatedStorage.ecs.components)
local Matter = require(Packages.Matter)

local function targetsSpawn(world: Matter.World)
	local now = DateTime.now().UnixTimestampMillis

	-- Give targets a health component when spawned.
	for eid, _target: Components.Target in world:query(Components.Target):without(Components.Health) do
		local targetHealth = Components.Health({
			current = 10,
			max = 10,
			healthPerSecond = 1,
		})

		world:insert(eid, targetHealth)
	end

	for eid, targetZone: Components.TargetZone, renderable: Components.Renderable<BasePart> in
		world:query(Components.TargetZone, Components.Renderable)
	do
		if
			targetZone.lastSpawnedTimestampMs == 0
			or now - targetZone.lastSpawnedTimestampMs >= targetZone.spawnIntervalMs
		then
			targetZone = targetZone:patch({
				lastSpawnedTimestampMs = now,
			})

			local zoneRenderable = renderable.pvInstance
			local zoneSize = zoneRenderable.Size

			local randomX = math.random(-zoneSize.X / 2, zoneSize.X / 2)
			local randomY = math.random(-zoneSize.Y / 2, zoneSize.Y / 2)
			local randomZ = math.random(-zoneSize.Z / 2, zoneSize.Z / 2)

			local targetSpawnPosition = zoneRenderable:GetPivot().Position + Vector3.new(randomX, randomY, randomZ)

			local targetCF = CFrame.lookAlong(targetSpawnPosition, zoneRenderable:GetPivot().LookVector)

			local targetClone = Targets:GetChildren()[math.random(1, #Targets:GetChildren())]:Clone() :: Model
			local targetPrimaryPart = targetClone.PrimaryPart :: BasePart

			local attachment = Instance.new("Attachment")
			attachment.Parent = targetPrimaryPart

			local linearVelocity = Instance.new("LinearVelocity")
			linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
			linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
			linearVelocity.VectorVelocity = Vector3.zero
			linearVelocity.MaxForce = math.huge
			linearVelocity.Attachment0 = attachment
			linearVelocity.Parent = targetPrimaryPart

			-- counteract gravity. if we dynamically add stuff to the assembly, we'd have to recalculate this.
			local vectorForce = Instance.new("VectorForce")
			vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
			vectorForce.Force = Vector3.new(0, workspace.Gravity * targetPrimaryPart:GetMass(), 0)
			vectorForce.Attachment0 = attachment
			vectorForce.Parent = targetPrimaryPart

			targetClone:PivotTo(targetCF)
			targetClone.Parent = workspace

			CollectionService:AddTag(targetClone, "Target") -- Our collection bootstrapper will make this an entity.

			world:insert(eid, targetZone)
		end
	end
end

return targetsSpawn
