--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService.Services

local EquipmentService = require(Services.EquipmentService)
local Matter = require(ReplicatedStorage.Packages.Matter)
local Components = require(ReplicatedStorage.ecs.components)

type healthChangeRecord = {
	new: Components.Health?,
	old: Components.Health?,
}

local function targetsDie(world: Matter.World)
	for eid, healthChangeRecord: healthChangeRecord in world:queryChanged(Components.Health) do
		if healthChangeRecord.new == nil then
			continue
		end
		local target: Components.Target? = world:get(eid, Components.Target)
		if not target then
			continue
		end
		if healthChangeRecord.new and healthChangeRecord.new.current <= 0 then
			local targetRenderable: Components.Renderable<Model> = world:get(eid, Components.Renderable)
			local targetPrimaryPart = targetRenderable.pvInstance.PrimaryPart :: BasePart

			-- When a target dies, we will drop a random amount of loot on the ground.
			EquipmentService:DropTargetLoot(targetPrimaryPart.Position)

			world:despawn(eid)
		end
	end
end

return targetsDie
