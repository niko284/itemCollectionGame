local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Matter = require(Packages.Matter)

return Matter.component("Target", {
	lifetimeMs = 10000,
	speed = 6,
	direction = Vector3.zero,
	updateVelocityMillis = 1000,
	lastVelocityChangeMillis = 0,
})
