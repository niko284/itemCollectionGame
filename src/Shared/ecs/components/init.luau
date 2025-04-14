--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = {}

local MatterTypes = require(ReplicatedStorage.ecs.MatterTypes)

for _, ComponentModule in ipairs(script:GetChildren()) do
	local Component = require(ComponentModule) :: any
	Components[tostring(Component)] = Component
end

export type TargetZone = MatterTypes.ComponentInstance<{
	lastSpawnedTimestampMs: number,
	spawnIntervalMs: number,
}>
export type Target = MatterTypes.ComponentInstance<{
	lifetimeMs: number, -- How long the target will last before being destroyed.
	easingStyle: Enum.EasingStyle, -- The easing style to use for the target's movement.
	easingDirection: Enum.EasingDirection, -- The easing direction to use for the target's movement.
	-- The target's position will be a random point within this radius of the original position.
	radius: number,
	goalPosition: Vector3,
	speed: number,
	-- The target's original position.
	originalPosition: Vector3,
	moveTween: Tween?, -- The tween used to move the target.
	expirationTimeMs: number, -- The time at which the target will expire.

	falling: boolean, -- Whether the target is falling after expiring or not.
}>
export type Renderable<T> = MatterTypes.ComponentInstance<{
	pvInstance: T & PVInstance,
}>

return Components
