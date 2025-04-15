--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.ecs.components)

local function targetsExpire(world: Matter.World)
	local now = DateTime.now().UnixTimestampMillis
	for eid, target: Components.Target, renderable: Components.Renderable<Model> in
		world:query(Components.Target, Components.Renderable)
	do
		if target.expirationTimeMs and target.expirationTimeMs <= now and not target.falling then
			target = target:patch({
				falling = true,
			})
			for _, part in renderable.pvInstance:GetDescendants() do
				if part:IsA("BasePart") then
					TweenService:Create(part, TweenInfo.new(1), {
						Transparency = 1,
						Size = Vector3.zero,
					}):Play()
				end
			end
			task.delay(1, function()
				if world:contains(eid) then -- we might've killed the target while it was shrinking in size
					world:despawn(eid)
				end
			end)
			world:insert(eid, target)
		end
	end
end

return targetsExpire
