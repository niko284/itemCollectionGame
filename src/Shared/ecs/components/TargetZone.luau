local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Matter = require(Packages.Matter)

return Matter.component("TargetZone", {
	lastSpawnedTimestampMs = 0, -- When was the last target spawned? (ms)
	spawnIntervalMs = 20000, -- How often to spawn targets in this zone? (ms)
})
