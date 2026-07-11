local StrictEnum = require("./../Utility/StrictEnum")

export type EnumType = "Bat" | "MetalBat" | "GoldenBat" | "RubyBat"

local WeaponName: StrictEnum.FromUnion<EnumType> = {
	Bat = "Bat",
	MetalBat = "MetalBat",
	GoldenBat = "GoldenBat",
	RubyBat = "RubyBat",
}

return table.freeze(WeaponName)
