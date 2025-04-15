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
	direction: Vector3, -- direction in which the target is moving.
	speed: number, -- current speed at which the target is moving.
	expirationTimeMs: number?, -- The time at which the target will expire. Gets instantiated on the first query.
	falling: boolean, -- Whether the target is falling after expiring or not.
	updateVelocityMillis: number, -- how often the target should update its velocity.
	lastVelocityChangeMillis: number, -- The last time the target updated its velocity.
}>
export type Renderable<T> = MatterTypes.ComponentInstance<{
	pvInstance: T & PVInstance,
}>

export type Gun = MatterTypes.ComponentInstance<{
	name: string,
	cooldownMillis: number, -- every how often can you shoot the gun?
	damage: number,
	range: number, 
	ammo: number,
	capacity: number, -- the maximum amount of ammo the gun can hold.
	reloadTimeMillis: number,
	owner: Player, -- the player who owns the gun.
	hitQueue: {HitEntry}, -- a queue of hit entries that the gun has made.
}>

export type Cooldown = MatterTypes.ComponentInstance<{
	expiry: number, -- the time at which the cooldown expires.
}>

export type HitEntry = {
	part: PVInstance,
}

export type Health = MatterTypes.ComponentInstance<{
	current: number, -- the current health of the entity.
	max: number, -- the maximum health of the entity.
	healthPerSecond: number, -- the amount of health the entity regenerates per second.
}>

return Components
