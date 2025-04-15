--!strict
local Types = require(script.Parent.Types)

return {
	{
		Type = "Sword",
		SpawnedByTarget = true,
		UniqueProps = {},
		CanEquip = true,
		EquippedAtOnce = 2,
	},
	{
		Type = "Gun",
		SpawnedByTarget = false,
		UniqueProps = {},
		EquippedAtOnce = 1,
		CanEquip = true,
	},
} :: { Types.ItemTypeInfo }
