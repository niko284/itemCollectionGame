--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Configuration = ReplicatedStorage.Configuration
local Services = ServerScriptService.Services
local Utilities = ReplicatedStorage.Utilities
local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)
local Signal = require(Packages.Signal)
local Freeze = require(Packages.Freeze)
local PlayerDataService = require(Services.PlayerDataService)
local ItemService = require(Services.ItemService)
local Items = require(Configuration.ItemConfig)
local Types = require(Configuration.Types)
local InventoryUtility = require(Utilities.InventoryUtility)
local ItemUtility = require(Utilities.ItemUtility)

local InventoryService = {
	Name = "InventoryService",
	Client = {
		ItemAdded = Knit.CreateSignal(),
		InventoryProperty = Knit.CreateProperty("PlayerInventory", nil), -- used to replicate the entire inventory (on init)
	},
	ItemEquipped = Signal.new(),
	ItemUnequipped = Signal.new(),
	InventoryLoaded = Signal.new(),
}

function InventoryService:KnitInit()
	PlayerDataService.DocumentLoaded:Connect(function(Player, Document)
		local documentData = Document:read()

		InventoryService:GrantDefaults(Player, Document)

		-- Replicate the inventory AFTER granting any new defaults so we don't have to go over the network twice.
		InventoryService.Client.InventoryProperty:SetFor(Player, documentData.Inventory)

		InventoryService.InventoryLoaded:Fire(Player, documentData.Inventory)
	end)
end

function InventoryService:GrantDefaults(Player: Player, Document): ()
	local documentData = Document:read()
	local grantedDefaults = table.clone(documentData.Inventory.GrantedDefaults)

	local wasGrantedAtLeastOne = false
	for _, itemInfo in Items do
		if not table.find(grantedDefaults, itemInfo.Name) then
			local isDefault = if typeof(itemInfo.Default) == "function"
				then itemInfo.Default(Player)
				else itemInfo.Default
			if isDefault ~= true then
				continue
			end
			ItemService:GenerateItem(itemInfo.Name)
				:andThen(function(Item: Types.InventoryItem)
					wasGrantedAtLeastOne = true
					table.insert(grantedDefaults, itemInfo.Name)
					InventoryService:AddItem(Player, Item, false) -- only called on init, so we replicate afterwards.
					InventoryService:EquipItem(Player, Item.UUID) -- equip the item.
				end)
				:catch(function(err: any)
					warn(string.format("Failed to grant default %s: %s", itemInfo.Name, tostring(err)))
				end)
				:awaitStatus()
		end
	end

	if wasGrantedAtLeastOne then -- if we granted at least one item, update the document with the new granted defaults.
		local newData = table.clone(Document:read())
		Document:write(Freeze.Dictionary.setIn(newData, { "Inventory", "GrantedDefaults" }, grantedDefaults))
	end
end

function InventoryService:AddItem(Player: Player, Item: Types.InventoryItem, SendOverNetwork: boolean?): ()
	local playerDocument = PlayerDataService:GetDocument(Player)
	if not playerDocument then
		warn("Failed to get player document")
		return
	end

	local newDocumentData = table.clone(playerDocument:read())
	local newInventory = InventoryUtility.AddItems(newDocumentData.Inventory, { Item })
	newDocumentData.Inventory = newInventory

	playerDocument:write(newDocumentData)

	if SendOverNetwork ~= false then -- Notify the client a new item was added to their inventory.
		InventoryService.Client.ItemAdded:Fire(Player, Item)
	end
end

function InventoryService:EquipItem(Player: Player, ItemUUID: string): ()
	local playerDocument = PlayerDataService:GetDocument(Player)
	if not playerDocument then
		warn("Failed to get player document")
		return
	end

	local newDocumentData = table.clone(playerDocument:read()) :: Types.PlayerDocument
	local newInventory = InventoryUtility.EquipItem(newDocumentData.Inventory, ItemUUID)
	newDocumentData.Inventory = newInventory

	playerDocument:write(newDocumentData)

	InventoryService.ItemEquipped:Fire(Player, ItemUUID)
end

function InventoryService:UnequipItem(Player: Player, ItemUUID: string): ()
	local playerDocument = PlayerDataService:GetDocument(Player)
	if not playerDocument then
		warn("Failed to get player document")
		return
	end

	local newDocumentData = table.clone(playerDocument:read()) :: Types.PlayerDocument
	local newInventory = InventoryUtility.UnequipItem(newDocumentData.Inventory, ItemUUID)
	newDocumentData.Inventory = newInventory

	playerDocument:write(newDocumentData)

	InventoryService.ItemUnequipped:Fire(Player, ItemUUID)
end

function InventoryService:GetItemFromUUID(Player: Player, ItemUUID: string): Types.InventoryItem?
	local playerDocument = PlayerDataService:GetDocument(Player)
	if not playerDocument then
		warn("Failed to get player document")
		return nil
	end

	local inventory = playerDocument:read().Inventory
	local item = InventoryUtility.GetItemFromUUID(inventory, ItemUUID)
	if not item then
		warn(string.format("Failed to get item from UUID %s", ItemUUID))
		return nil
	end

	return item
end

function InventoryService.Client:EquipItem(Player: Player, ItemUUID: any?): Types.NetworkResponse
	local Document = PlayerDataService:GetDocument(Player)
	if not Document then
		return { Success = false, Error = "Document not found" }
	end

	if not ItemUUID or typeof(ItemUUID) ~= "string" then
		return { Success = false, Error = "Invalid ItemUUID" }
	end

	local documentData = Document:read()
	local inventory = documentData.Inventory

	local Item = InventoryUtility.GetItemFromUUID(inventory, ItemUUID)
	if not Item then
		return { Success = false, Error = "Item not found" }
	end

	local ItemInfo = ItemUtility.GetItemInfoFromName(Item.Name)

	if not ItemInfo then
		return { Success = false, Error = "ItemInfo not found" }
	end

	local ItemTypeInfo = ItemUtility.GetItemTypeInfoFromName(ItemInfo.Type)

	if not ItemTypeInfo then
		return { Success = false, Error = "ItemTypeInfo not found" }
	end

	if ItemTypeInfo.CanEquip == false then
		return { Success = false, Error = "Item cannot be equipped" }
	end

	InventoryService:EquipItem(Player, ItemUUID)

	return { Success = true }
end

function InventoryService.Client:UnequipItem(Player: Player, ItemUUID: any?): Types.NetworkResponse
	local Document = PlayerDataService:GetDocument(Player)
	if not Document then
		return { Success = false, Error = "Document not found" }
	end

	local inventory = Document:read().Inventory

	if not ItemUUID or typeof(ItemUUID) ~= "string" then
		return { Success = false, Error = "Invalid ItemUUID" }
	end

	local Item = InventoryUtility.GetItemFromUUID(inventory, ItemUUID)
	if not Item then
		return { Success = false, Error = "Item not found" }
	end

	local ItemInfo = ItemUtility.GetItemInfoFromName(Item.Name)

	if not ItemInfo then
		return { Success = false, Error = "ItemInfo not found" }
	end

	local ItemTypeInfo = ItemUtility.GetItemTypeInfoFromName(ItemInfo.Type)

	if not ItemTypeInfo then
		return { Success = false, Error = "ItemTypeInfo not found" }
	end

	if ItemTypeInfo.CanEquip == false then
		return { Success = false, Error = "Item cannot be unequipped" }
	end

	InventoryService:UnequipItem(Player, ItemUUID)

	return { Success = true }
end

return InventoryService
