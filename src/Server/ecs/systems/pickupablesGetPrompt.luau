--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService.Services
local Packages = ReplicatedStorage.Packages
local Configuration = ReplicatedStorage.Configuration

local Matter = require(Packages.Matter)
local Components = require(ReplicatedStorage.ecs.components)
local Types = require(Configuration.Types)
local InventoryService = require(Services.InventoryService)
local ItemService = require(Services.ItemService)

local function pickupablesGetPrompt(world: Matter.World)
	for entity, pickupableChangeRecord in world:queryChanged(Components.Pickupable) do
		if pickupableChangeRecord.new and not pickupableChangeRecord.old then
			local renderable: Components.Renderable<Model> = world:get(entity, Components.Renderable)
			if renderable then
				local renderableModel = renderable.pvInstance
				local attachmentPart = renderableModel.PrimaryPart :: BasePart
				if attachmentPart:FindFirstChildOfClass("ProximityPrompt") then
					continue
				end
				local proximityPrompt = Instance.new("ProximityPrompt")
				proximityPrompt.ActionText = "Pickup"
				proximityPrompt.ObjectText = renderableModel:GetAttribute("PickupableName") :: string
				proximityPrompt.RequiresLineOfSight = false
				proximityPrompt.MaxActivationDistance = 10
				proximityPrompt.HoldDuration = 0.5

				attachmentPart.Material = Enum.Material.ForceField

				proximityPrompt.Triggered:Once(function(playerTriggered: Player)
					local itemName = renderableModel:GetAttribute("PickupableName") :: string
					-- reward the player the item.
					if itemName then
						ItemService:GenerateItem(itemName)
							:andThen(function(item: Types.InventoryItem)
								InventoryService:AddItem(playerTriggered, item, true)
							end)
							:catch(function(err: any)
								warn(tostring(err))
							end)
					end

					if world:contains(entity) then
						world:despawn(entity) -- remove the pickupable from the world
					end
				end)

				proximityPrompt.Parent = renderableModel
			end
		end
	end
end

return pickupablesGetPrompt
