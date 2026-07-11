local StrictEnum = require("./../Utility/StrictEnum")
-- Currently unused, setup for future needs.

export type EnumType = "Placeable" | "Explosive"

local ItemTagEnum: StrictEnum.FromUnion<EnumType> = {
	Placeable = "Placeable",
	Explosive = "Explosive",
}

return ItemTagEnum
