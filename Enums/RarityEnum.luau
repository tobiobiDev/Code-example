local StrictEnum = require("./../Utility/StrictEnum")

export type EnumType =
	"Common"
	| "Uncommon"
	| "Rare"
	| "Epic"
	| "Legendary"
	| "Mythical"
	| "Divine"
	| "Secret"
	| "Celestial"

export type WallEnumType =
	"CommonWall"
	| "UncommonWall"
	| "RareWall"
	| "EpicWall"
	| "LegendaryWall"
	| "MythicalWall"
	| "DivineWall"
	| "SecretWall"
	| "CelestialWall"

local RarityEnum: StrictEnum.FromUnion<EnumType> = {
	Common = "Common",
	Uncommon = "Uncommon",
	Rare = "Rare",
	Epic = "Epic",
	Legendary = "Legendary",
	Mythical = "Mythical",
	Divine = "Divine",
	Secret = "Secret",
	Celestial = "Celestial",
}

return table.freeze(RarityEnum)
