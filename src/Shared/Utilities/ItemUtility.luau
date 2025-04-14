--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Configuration = ReplicatedStorage.Configuration

local ItemTypes = require(Configuration.ItemTypeConfig)
local Items = require(Configuration.ItemConfig)
local Types = require(Configuration.Types)

local ItemUtility = {}

function ItemUtility.GetItemInfoFromName(ItemName: string): Types.ItemInfo?
	for _, itemInfo in Items do
		if itemInfo.Name == ItemName then
			return itemInfo
		end
	end
	return nil
end

function ItemUtility.GetItemTypeInfoFromName(ItemType: string): Types.ItemTypeInfo?
	for _, itemTypeInfo in ItemTypes do
		if itemTypeInfo.Type == ItemType then
			return itemTypeInfo
		end
	end
	return nil
end

return ItemUtility
