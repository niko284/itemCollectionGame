--!strict

-- Collection of util functions that will immutably modify the inventory.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Configuration = ReplicatedStorage.Configuration
local Utilities = ReplicatedStorage.Utilities
local Packages = ReplicatedStorage.Packages

local Freeze = require(Packages.Freeze)
local Types = require(Configuration.Types)
local ItemUtility = require(Utilities.ItemUtility)
local StringUtility = require(Utilities.StringUtility)

local InventoryUtility = {}

-- Returns an immutable copy of the inventory with the item equipped

function InventoryUtility.IsEquipped(Inventory: Types.Inventory, ItemUUID: string): boolean
	for _, item in Inventory.Equipped do
		if item.UUID == ItemUUID then
			return true
		end
	end

	return false
end

function InventoryUtility.EquipItem(Inventory: Types.Inventory, ItemUUID: string): Types.Inventory
	local newInventory = table.clone(Inventory)
	local newStorage = table.clone(newInventory.Storage)
	local newEquipped = table.clone(newInventory.Equipped)

	local indexToRemove: number? = nil
	for index, storageItem in newStorage do
		if storageItem.UUID == ItemUUID then
			indexToRemove = index
			break
		end
	end

	if not indexToRemove then
		return newInventory
	end

	local itemInfo = ItemUtility.GetItemInfoFromName(newStorage[indexToRemove].Name)

	if not itemInfo then
		warn("ItemInfo not found for item: " .. newStorage[indexToRemove].Name)
		return newInventory
	end

	local itemTypeInfo = ItemUtility.GetItemTypeInfoFromName(itemInfo.Type)

	if not itemTypeInfo then
		warn("ItemTypeInfo not found for item: " .. itemInfo.Name)
		return newInventory
	end

	local equippedAtOnce = if typeof(itemTypeInfo.EquippedAtOnce) == "function"
		then itemTypeInfo.EquippedAtOnce(itemInfo)
		else itemTypeInfo.EquippedAtOnce

	if equippedAtOnce then
		local equippedItems = InventoryUtility.GetItemsOfType(Inventory, itemInfo.Type, true)
		if #equippedItems >= equippedAtOnce then -- unequip one item if we're at the limit using the first item in the alphabet to sync with the client-side prediction
			local _uuid, index =
				StringUtility.GetFirstStringInAlphabet(Freeze.List.map(equippedItems, function(itemOfType)
					return itemOfType.UUID
				end))
			newInventory = InventoryUtility.UnequipItem(newInventory, equippedItems[index].UUID)
			newStorage = newInventory.Storage
			newEquipped = newInventory.Equipped
		end
	end

	local Item = table.remove(newStorage, indexToRemove) :: Types.InventoryItem
	table.insert(newEquipped, Item)

	newInventory.Storage = newStorage
	newInventory.Equipped = newEquipped

	return newInventory
end

function InventoryUtility.GetItemsOfType(
	Inventory: Types.Inventory,
	ItemType: Types.ItemType,
	Equipped: boolean?
): { Types.InventoryItem }
	local items = if Equipped == true then Inventory.Equipped else Inventory.Storage

	local filteredItems = {} :: { Types.InventoryItem }
	for _, item in pairs(items) do
		local itemInfo = ItemUtility.GetItemInfoFromName(item.Name)
		if not itemInfo then
			warn("ItemInfo not found for item: " .. item.Name)
			continue
		end
		if itemInfo.Type == ItemType then
			table.insert(filteredItems, item :: any)
		end
	end

	return filteredItems
end

function InventoryUtility.UnequipItem(Inventory: Types.Inventory, ItemUUID: string): Types.Inventory
	local newInventory = table.clone(Inventory)
	local newStorage = table.clone(newInventory.Storage)
	local newEquipped = table.clone(newInventory.Equipped)

	local indexToRemove = nil
	for index, item in ipairs(newEquipped) do
		if item.UUID == ItemUUID then
			indexToRemove = index
			break
		end
	end

	if not indexToRemove then
		return newInventory
	end

	local Item = table.remove(newEquipped, indexToRemove) :: Types.InventoryItem
	table.insert(newStorage, Item)

	newInventory.Storage = newStorage
	newInventory.Equipped = newEquipped

	return newInventory
end

function InventoryUtility.AddItems(Inventory: Types.Inventory, Items: { Types.InventoryItem }): Types.Inventory
	local newInventory = table.clone(Inventory)
	local newStorage = table.clone(newInventory.Storage)

	for _, item in Items do
		table.insert(newStorage, item)
	end

	newInventory.Storage = newStorage

	return newInventory
end

function InventoryUtility.GetItemFromUUID(Inventory: Types.Inventory, ItemUUID: string): Types.InventoryItem?
	for _, item in Inventory.Storage do
		if item.UUID == ItemUUID then
			return item
		end
	end

	for _, item in Inventory.Equipped do
		if item.UUID == ItemUUID then
			return item
		end
	end

	return nil
end

return InventoryUtility
