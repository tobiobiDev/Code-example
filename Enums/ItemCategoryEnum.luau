local StrictEnum = require("./../Utility/StrictEnum")

export type EnumType = "Utility" | "Explosive" | "Traversal" | "Automation" | "Support"

local ItemCategoryEnum: StrictEnum.FromUnion<EnumType> = {
	Utility = "Utility",
	Explosive = "Explosive",
	Traversal = "Traversal",
	Automation = "Automation",
	Support = "Support",
}

return table.freeze(ItemCategoryEnum)
