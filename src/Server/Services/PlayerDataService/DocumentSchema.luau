--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Configuration = ReplicatedStorage.Configuration

local Types = require(Configuration.Types)

return {
	Inventory = {
		Storage = {},
		Equipped = {},
		GrantedDefaults = {},
	},
} :: Types.PlayerDocument
