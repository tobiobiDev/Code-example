local StrictEnum = require("./../Utility/StrictEnum")

export type EnumType = "Normal" | "Gold" | "Diamond" | "Ruby" | "Blaze"

local MutationEnum: StrictEnum.FromUnion<EnumType> = {
	Normal = "Normal",
	Gold = "Gold",
	Diamond = "Diamond",
	Ruby = "Ruby",
	Blaze = "Blaze",
}

return table.freeze(MutationEnum)
