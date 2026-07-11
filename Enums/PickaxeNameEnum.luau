local StrictEnum = require("./../Utility/StrictEnum")

export type EnumType =
	"Adamantite"
	| "Amethyst"
	| "Bronze"
	| "Copper"
	| "Demonite"
	| "Emerald"
	| "Gold"
	| "Iron"
	| "Mithril"
	| "Obsidian"
	| "Onyx"
	| "Platinum"
	| "Ruby"
	| "Sapphire"
	| "Silver"
	| "Steel"
	| "Stone"
	| "Void"

local PickaxeName: StrictEnum.FromUnion<EnumType> = {
	Adamantite = "Adamantite",
	Amethyst = "Amethyst",
	Bronze = "Bronze",
	Copper = "Copper",
	Demonite = "Demonite",
	Emerald = "Emerald",
	Gold = "Gold",
	Iron = "Iron",
	Mithril = "Mithril",
	Obsidian = "Obsidian",
	Onyx = "Onyx",
	Platinum = "Platinum",
	Ruby = "Ruby",
	Sapphire = "Sapphire",
	Silver = "Silver",
	Steel = "Steel",
	Stone = "Stone",
	Void = "Void",
}

return table.freeze(PickaxeName)
