--!strict

export type ItemInfo = {
	Name: string,
	Type: ItemType,
	Default: (boolean | (Player) -> boolean)?,
}

export type ItemTypeInfo = {
	Type: ItemType,
	CanEquip: boolean,
	SpawnedByTarget: boolean,
	UniqueProps: {
		[string]: any,
	},
	EquippedAtOnce: (number | (ItemInfo) -> number)?,
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

export type ItemType = "Sword" | "Gun"

export type Sound = {
	Id: number,
	Volume: number,
	Looped: boolean,
}

export type NetworkResponse = {
	Success: boolean,
	Error: string?,
}

return {}
