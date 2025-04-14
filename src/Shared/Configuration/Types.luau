--!strict

export type ItemInfo = {
	Name: string,
	Type: string,
	Default: (boolean | (Player) -> boolean)?,
}

export type ItemTypeInfo = {
	Type: string,
	SpawnedByTarget: boolean,
	UniqueProps: {
		[string]: any,
	},
}

export type InventoryItem = {
	Name: string,
	UUID: string,
} & { [string]: any } -- unique props.

export type Inventory = {
	Storage: { InventoryItem },
	Equipped: { InventoryItem },
	GrantedDefaults: { string }, -- List of item names.
}

export type PlayerDocument = {
	Inventory: Inventory,
}

export type ItemType = "Sword"

return {}
