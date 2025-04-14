--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Configuration = ReplicatedStorage.Configuration
local Services = ServerScriptService.Services
local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)
local Freeze = require(Packages.Freeze)
local PlayerDataService = require(Services.PlayerDataService)
local ItemService = require(Services.ItemService)
local Items = require(Configuration.ItemConfig)
local Types = require(Configuration.Types)

local InventoryService = {
	Name = "InventoryService",
	Client = {
		ItemAdded = Knit.CreateSignal(),
		InventoryProperty = Knit.CreateProperty("PlayerInventory"), -- used to replicate the entire inventory (on init)
	},
}

function InventoryService:KnitInit()
	PlayerDataService.DocumentLoaded:Connect(function(Player, Document)
		local documentData = Document:read()

		InventoryService:GrantDefaults(Player, Document)

		-- Replicate the inventory AFTER granting any new defaults so we don't have to go over the network twice.
		InventoryService.Client.InventoryProperty:SetFor(Player, documentData.Inventory)
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
	local newStorage = table.clone(newDocumentData.Inventory.Storage)

	table.insert(newStorage, Item)

	playerDocument:write(Freeze.Dictionary.setIn(newDocumentData, { "Inventory", "Storage" }, newStorage))

	if SendOverNetwork ~= false then -- Notify the client a new item was added to their inventory.
		InventoryService.Client.ItemAdded:Fire(Player, Item)
	end
end

return InventoryService
