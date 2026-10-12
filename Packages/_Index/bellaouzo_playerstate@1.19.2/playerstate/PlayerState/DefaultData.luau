export type InventoryItem = {
	itemName: string,
	quantity: number,
}

export type Inventory = {
	Pills: { [string]: InventoryItem },
	Elixirs: { [string]: InventoryItem },
}

export type PlayerData = {
	Coins: number,
	Inventory: Inventory,

	session: {
		plotId: string?,
	},

	Server: {},

	leaderstats: {
		["💰 Coins"]: string,
	},
}

local DEFAULT_DATA: PlayerData = {
	Coins = 0,

	Inventory = {
		Pills = {},
		Elixirs = {},
	},

	session = {
		plotId = nil,
	},

	Server = {},

	leaderstats = {
		["💰 Coins"] = "Coins",
	},
}

return DEFAULT_DATA