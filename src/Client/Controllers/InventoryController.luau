--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Configuration = ReplicatedStorage.Configuration

local Types = require(Configuration.Types)
local Knit = require(Packages.Knit)
local Signal = require(Packages.Signal)

local InventoryController = {
	Name = "InventoryController",
	InventoryChanged = Signal.new(),
	_inventory = nil :: any,
	InventoryService = nil :: any,
}

function InventoryController:KnitStart()
	local InventoryService = Knit.GetService("InventoryService")
	self.InventoryService = InventoryService
	InventoryService.InventoryProperty:Observe(function(inventory: Types.Inventory?)
		if inventory then
			self._inventory = inventory
			self.InventoryChanged:Fire(inventory)
		end
	end)
	InventoryService.ItemAdded:Connect(function(newItem: Types.InventoryItem)
		if self._inventory then
			table.insert(self._inventory.Storage, newItem)
			self.InventoryChanged:Fire(self._inventory)
		end
	end)
end

function InventoryController:SetInventory(inventory: Types.Inventory): ()
	self._inventory = inventory
	self.InventoryChanged:Fire(inventory)
end

function InventoryController:GetInventory(): Types.Inventory
	return self._inventory :: Types.Inventory
end

return InventoryController
