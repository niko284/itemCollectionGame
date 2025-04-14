local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Matter = require(Packages.Matter)

return Matter.component("Target", {
	lifetimeMs = 10000, -- How long the target will last before being destroyed.
	easingStyle = Enum.EasingStyle.Linear, -- The easing style to use for the target's movement.
	easingDirection = Enum.EasingDirection.InOut, -- The easing direction to use for the target's movement.
	-- The target's position will be a random point within this radius of the original position.
	radius = 10,
	goalPosition = Vector3.zero,
	speed = 5, -- studs per second which the target will move.
	moveTween = nil :: Tween?, -- The tween used to move the target.
})
