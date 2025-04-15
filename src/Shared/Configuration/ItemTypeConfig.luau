--!strict
local Types = require(script.Parent.Types)

return {
	{
		Type = "Sword",
		SpawnedByTarget = true,
		UniqueProps = {},
	},
	{
		Type = "Gun",
		SpawnedByTarget = false,
		UniqueProps = {},
		EquippedAtOnce = 1,
	}
} :: { Types.ItemTypeInfo }
