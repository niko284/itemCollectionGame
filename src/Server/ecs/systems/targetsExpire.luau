--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.ecs.components)

local function targetsExpire(world: Matter.World)
	local now = DateTime.now().UnixTimestampMillis
	for eid, target: Components.Target, renderable: Components.Renderable<Model> in
		world:query(Components.Target, Components.Renderable)
	do
		if target.expirationTimeMs and target.expirationTimeMs <= now and not target.falling then
			if target.moveTween then
				target.moveTween:Cancel()
			end
			target = target:patch({
				falling = true,
			})
			world:insert(eid, target)
			for _, part in renderable.pvInstance:GetDescendants() do
				if part:IsA("BasePart") then
					part.Anchored = false
					part.CanCollide = false
				end
			end
			task.delay(5, function()
				if renderable.pvInstance then
					renderable.pvInstance:Destroy() -- this will despawn the entity as well.
				end
			end)
		end
	end
end

return targetsExpire
