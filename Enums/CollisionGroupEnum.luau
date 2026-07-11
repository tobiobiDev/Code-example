local StrictEnum = require("./../Utility/StrictEnum")

export type EnumType = "Characters" | "Fragments" | "CaveWalls"

local CollisionGroup: StrictEnum.FromUnion<EnumType> = {
	Characters = "Characters",
	Fragments = "Fragments",
	CaveWalls = "CaveWalls",
}

return table.freeze(CollisionGroup)
