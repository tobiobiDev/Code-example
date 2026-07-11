--!strict

local StrictEnum = require("./../Utility/StrictEnum")

export type EnumType =
	"ScaffoldingSmall"
	| "ScaffoldingLarge"
	| "Dynamite"
	| "DynamiteBundle"
	| "Bomb"
	| "MakeshiftStickyBomb"

local ItemIdEnum: StrictEnum.FromUnion<EnumType> = {
	ScaffoldingSmall = "ScaffoldingSmall",
	ScaffoldingLarge = "ScaffoldingLarge",
	Dynamite = "Dynamite",
	DynamiteBundle = "DynamiteBundle",
	Bomb = "Bomb",
	MakeshiftStickyBomb = "MakeshiftStickyBomb",
}

return table.freeze(ItemIdEnum)
