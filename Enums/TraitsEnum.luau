local StrictEnum = require("./../Utility/StrictEnum")

export type EnumType =
	"Traitless"
	| "Ancient"
	| "Ancient Wealth"
	| "Ascended"
	| "Efficient"
	| "Enhanced"
	| "Godlike"
	| "Golden Touch"
	| "Greedy"
	| "Hyperactive"
	| "Loaded"
	| "Radiating"

local TraitsEnum: StrictEnum.FromUnion<EnumType> = {
	Traitless = "Traitless",
	Ancient = "Ancient",
	["Ancient Wealth"] = "Ancient Wealth",
	Ascended = "Ascended",
	Efficient = "Efficient",
	Enhanced = "Enhanced",
	Godlike = "Godlike",
	["Golden Touch"] = "Golden Touch",
	Greedy = "Greedy",
	Hyperactive = "Hyperactive",
	Loaded = "Loaded",
	Radiating = "Radiating",
}

return table.freeze(TraitsEnum)
