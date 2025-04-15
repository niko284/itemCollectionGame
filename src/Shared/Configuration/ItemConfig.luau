--!strict

local Types = require(script.Parent.Types)

return {
	{
		Name = "Darkheart",
		Type = "Sword",
	},
	{
		Name = "Venomshank",
		Type = "Sword",
	},
	{
		Name = "Revolver",
		Type = "Gun",
		Default = true,
	}
} :: { Types.ItemInfo }
