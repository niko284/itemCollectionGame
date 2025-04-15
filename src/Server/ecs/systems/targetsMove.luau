--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage.Packages

local Components = require(ReplicatedStorage.ecs.components)
local Matter = require(Packages.Matter)

local RNG = Random.new(workspace:GetServerTimeNow())

local function targetsMove(world: Matter.World)
	local now = DateTime.now().UnixTimestampMillis
	for eid, target: Components.Target, renderable: Components.Renderable<Model> in
		world:query(Components.Target, Components.Renderable)
	do
		-- Wait for the previous velocity update to finish before starting a new one.
		if
			(
				target.lastVelocityChangeMillis == 0
				or now - target.lastVelocityChangeMillis >= target.updateVelocityMillis
			) and not target.falling
		then
			if not target.expirationTimeMs then
				target = target:patch({
					expirationTimeMs = now + target.lifetimeMs,
				})
			end

			local targetModel = renderable.pvInstance
			local targetPrimaryPart = targetModel.PrimaryPart :: BasePart

			local randomDirection = RNG:NextUnitVector()

			local linearVelocity = targetPrimaryPart:FindFirstChildOfClass("LinearVelocity")
			if linearVelocity then
				linearVelocity.VectorVelocity = randomDirection * target.speed
			end

			target = target:patch({
				lastVelocityChangeMillis = now,
				direction = randomDirection,
			})

			world:insert(eid, target)
		end
	end
end

return targetsMove
