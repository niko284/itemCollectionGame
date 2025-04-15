--!strict

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = ServerScriptService.Services
local Packages = ReplicatedStorage.Packages
local Utilities = ReplicatedStorage.Utilities
local Configuration = ReplicatedStorage.Configuration

local Assets = ServerStorage:FindFirstChild("assets") :: Folder
local ItemsFolder = Assets:FindFirstChild("items") :: Folder
local Swords = ItemsFolder:FindFirstChild("swords") :: Folder

local ItemUtility = require(Utilities.ItemUtility)
local InventoryService = require(Services.InventoryService)
local Types = require(Configuration.Types)
local Items = require(Configuration.ItemConfig)
local GunConfig = require(Configuration.GunConfig)
local Matter = require(Packages.Matter)
local Freeze = require(Packages.Freeze)
local Components = require(ReplicatedStorage.ecs.components)

local EquipmentService = {
	Name = "EquipmentService",
	Client = {},
	World = nil :: Matter.World?,
}

function EquipmentService:KnitInit()
	InventoryService.InventoryLoaded:Connect(function(Player: Player, Inventory: Types.Inventory)
		for _, equippedItem in Inventory.Equipped do
			local itemInfo = ItemUtility.GetItemInfoFromName(equippedItem.Name)
			if itemInfo then
				EquipmentService:HandleItemEquipped(Player, equippedItem, itemInfo)
			end
		end

		local first = true -- Used to check if the player is joining for the first time.

		Player.CharacterAdded:Connect(function()
			if first then
				first = false -- Set to false so we don't run this again.
				return
			end
			for _, equippedItem in Inventory.Equipped do
				local itemInfo = ItemUtility.GetItemInfoFromName(equippedItem.Name)
				if itemInfo then
					EquipmentService:HandleItemEquipped(Player, equippedItem, itemInfo, true)
				end
			end
		end)
	end)

	InventoryService.ItemEquipped:Connect(function(Player, ItemUUID)
		local inventoryItem = InventoryService:GetItemFromUUID(Player, ItemUUID)

		if inventoryItem then
			local inventoryItemInfo = ItemUtility.GetItemInfoFromName(inventoryItem.Name)
			if inventoryItemInfo then
				EquipmentService:HandleItemEquipped(Player, inventoryItem, inventoryItemInfo)
			end
		end
	end)

	InventoryService.ItemUnequipped:Connect(function(Player, ItemUUID)
		local inventoryItem = InventoryService:GetItemFromUUID(Player, ItemUUID)

		if inventoryItem then
			local inventoryItemInfo = ItemUtility.GetItemInfoFromName(inventoryItem.Name)
			if inventoryItemInfo then
				EquipmentService:HandleItemUnequipped(Player, inventoryItem, inventoryItemInfo)
			end
		end
	end)
end

function EquipmentService:HandleItemEquipped(
	Player: Player,
	InventoryItem: Types.InventoryItem,
	ItemInfo: Types.ItemInfo,
	ReEquipping: boolean? -- If the item is being re-equipped, we don't want to spawn it again. (guns)
)
	if ItemInfo.Type == "Gun" and not ReEquipping then
		-- Insert a gun component into our world.
		local world = EquipmentService.World
		if world then
			local gunData = table.clone(GunConfig[InventoryItem.Name])
			gunData.owner = Player -- Set the owner of the gun to the player.
			gunData.name = InventoryItem.Name
			world:spawn(Components.Gun(gunData))
		end
	elseif ItemInfo.Type == "Sword" then
		-- Give the gear in their backpack.
		local swordFolder = Swords:FindFirstChild(InventoryItem.Name) :: Folder?
		if not swordFolder then
			warn("Sword folder " .. InventoryItem.Name .. " not found in swords.")
			return
		end
		local swordTool = swordFolder:FindFirstChildOfClass("Tool") :: Tool?
		if not swordTool then
			warn("Sword tool not found in " .. swordFolder:GetFullName())
			return
		end
		local swordClone = swordTool:Clone()
		if not Player.Character then
			Player.CharacterAdded:Wait()
		end
		swordClone.Parent = Player:WaitForChild("Backpack")
	end
end

function EquipmentService:HandleItemUnequipped(
	Player: Player,
	InventoryItem: Types.InventoryItem,
	ItemInfo: Types.ItemInfo
)
	if ItemInfo.Type == "Gun" then
		-- Remove the gun component from our world.
		local world = EquipmentService.World
		if world then
			local gunEntity
			for entity, gun: Components.Gun in world:query(Components.Gun) do
				if gun.owner == Player and gun.name == InventoryItem.Name then
					gunEntity = entity
					break
				end
			end
			if gunEntity then
				world:despawn(gunEntity)
			end
		end
	elseif ItemInfo.Type == "Sword" then
		-- Remove the sword from the player's backpack.
		local swordFolder = Swords:FindFirstChild(InventoryItem.Name) :: Folder?
		if not swordFolder then
			warn("Sword folder " .. InventoryItem.Name .. " not found in swords.")
			return
		end
		local swordTool = swordFolder:FindFirstChildOfClass("Tool") :: Tool?
		if not swordTool then
			warn("Sword tool not found in " .. swordFolder:GetFullName())
			return
		end
		local swordClone = Player.Backpack:FindFirstChild(swordTool.Name) :: Tool?
		if swordClone then
			swordClone:Destroy()
		end
		-- Remove the sword from the player's character if they are holding it.
		local character = Player.Character
		if character then
			local swordInCharacter = character:FindFirstChild(swordTool.Name) :: Tool?
			if swordInCharacter then
				swordInCharacter:Destroy()
			end
		end
	end
end

function EquipmentService:DropTargetLoot(targetPosition: Vector3)
	local amountOfLoot = math.random(1, 3)

	-- Get all items that can be dropped by a target.

	local droppableItems = Freeze.List.filter(Items, function(itemInfo: Types.ItemInfo)
		local itemTypeInfo = ItemUtility.GetItemTypeInfoFromName(itemInfo.Type)
		if not itemTypeInfo then
			return false
		end
		return itemTypeInfo.SpawnedByTarget == true
	end)

	local randomItems = {} :: { Types.ItemInfo }

	for _ = 1, amountOfLoot do
		local randomIndex = math.random(1, #droppableItems)
		local randomItem = droppableItems[randomIndex]
		table.insert(randomItems, randomItem)
	end

	-- Find each items renderable model and spawn it at the target position. These are like "Pickupable" items.=
	-- that will get tagged by our ECS collection bootstrapper.

	for _, item in randomItems do
		local itemFolder = ItemsFolder:FindFirstChild(item.Name, true) :: Folder?
		if not itemFolder then
			warn("Item folder " .. item.Name .. " not found in items.")
			continue
		end
		local itemPickupable = itemFolder:FindFirstChild("Pickupable") :: Model?
		if not itemPickupable then
			warn("Item pickupable model not found in " .. itemFolder:GetFullName())
			continue
		end
		local itemClone = itemPickupable:Clone()
		itemClone:SetAttribute("PickupableName", item.Name)
		itemClone:AddTag("Pickupable")
		itemClone:PivotTo(CFrame.new(targetPosition))
		itemClone.Parent = workspace
	end
end

return EquipmentService
