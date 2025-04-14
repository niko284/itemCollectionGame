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
			targetClone:PivotTo(targetCF)
			targetClone.Parent = workspace

			CollectionService:AddTag(targetClone, "Target") -- Our collection bootstrapper will make this an entity.

			world:insert(eid, targetZone)
		end
	end
end

return targetsSpawn
