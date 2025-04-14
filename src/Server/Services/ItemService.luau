--!strict

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Utilities = ReplicatedStorage.Utilities
local Configuration = ReplicatedStorage.Configuration

local Types = require(Configuration.Types)
local ItemUtility = require(Utilities.ItemUtility)
local Promise = require(Packages.Promise)

local ItemService = {
	Name = "ItemService",
	Client = {},
}

function ItemService:GenerateItem(ItemName: string)
	return Promise.new(function(resolve, reject)
		local ItemInformation = ItemUtility.GetItemInfoFromName(ItemName)

		if not ItemInformation then
			reject("Failed to get item information for ", ItemName)
			return
		end

		local ItemTypeInformation = ItemUtility.GetItemTypeInfoFromName(ItemInformation.Type)
		if not ItemTypeInformation then
			reject("Failed to get item type information for ", ItemName)
			return
		end

		local NewItem: Types.InventoryItem = {
			UUID = HttpService:GenerateGUID(false),
			Name = ItemInformation.Name,
		}

		-- Get unique properties of the item based on its type and add them to the item
		if ItemTypeInformation.UniqueProps then
			for Property, Value in ItemTypeInformation.UniqueProps do
				NewItem[Property] = Value
			end
		end

		resolve(NewItem)
	end)
end

return ItemService
