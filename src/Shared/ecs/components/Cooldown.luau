local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)

local Cooldown = Matter.component("Cooldown", {
	expiry = 0,
})

return Cooldown