local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Components = require(ReplicatedStorage.ecs.components)

local name = RunService:IsServer() and "serverEntityId" or "clientEntityId"

type RenderableRecord = {
	new: Components.Renderable<Instance>?,
	old: Components.Renderable<Instance>,
}

local function updateModelAttribute(world)
	for id, record in world:queryChanged(Components.Renderable) do
		if record.new then
			record.new.pvInstance:SetAttribute(name, id)
		end
	end
end

return updateModelAttribute