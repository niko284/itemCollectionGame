local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Matter = require(Packages.Matter)

return Matter.component("Target", {
	lifetimeMs = 10000,
	speed = 25,
	direction = Vector3.zero,
	updateVelocityMillis = 250,
	lastVelocityChangeMillis = 0,
})
